"""
Catalog Views
==============
REST API endpoints for songs, genres, lyrics, and external search.

Implements the API contract from BACKEND_STRUCTURE.md:
    GET  /api/songs/            — List songs with search/filter
    GET  /api/songs/{id}/       — Song detail with lyrics
    GET  /api/songs/{id}/lyrics/— Dedicated lyrics endpoint
    GET  /api/genres/           — Genre listing with counts
    GET  /api/search/           — Broker search (local + MusicBrainz + LRCLIB)
"""

import logging
from django.db.models import Q, Count
from rest_framework import status
from rest_framework.generics import ListAPIView, RetrieveAPIView, GenericAPIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response

from .models import Artist, Song, SongLyricLine
from .serializers import (
    SongListSerializer,
    SongDetailSerializer,
    LyricLineSerializer,
    GenreSerializer,
    ExternalSearchResultSerializer,
)

logger = logging.getLogger(__name__)


class SongListView(ListAPIView):
    """
    GET /api/songs/

    List songs with optional search and genre filtering.
    Query params:
        q       — Search by title or artist name
        genre   — Filter by genre
    """
    serializer_class = SongListSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        queryset = Song.objects.select_related('artist').all()

        # Search filter
        query = self.request.query_params.get('q', '').strip()
        if query:
            queryset = queryset.filter(
                Q(title__icontains=query) |
                Q(artist__name__icontains=query)
            )

        # Genre filter
        genre = self.request.query_params.get('genre', '').strip()
        if genre:
            queryset = queryset.filter(genre__iexact=genre)

        return queryset


class SongDetailView(RetrieveAPIView):
    """
    GET /api/songs/{id}/

    Fetch full song metadata, signed media URLs, and synced lyrics.
    Also increments the play count.
    """
    serializer_class = SongDetailSerializer
    permission_classes = [AllowAny]
    queryset = Song.objects.select_related('artist').prefetch_related('lyrics')

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()

        # Increment play count
        Song.objects.filter(pk=instance.pk).update(plays=instance.plays + 1)

        serializer = self.get_serializer(instance)
        return Response(serializer.data)


class SongLyricsView(GenericAPIView):
    """
    GET /api/songs/{id}/lyrics/

    Dedicated lyrics endpoint optimized for Flutter's real-time sync display.
    Returns all lyric lines sorted by timestamp with word-level timing when available.
    """
    permission_classes = [AllowAny]

    def get(self, request, pk):
        try:
            song = Song.objects.get(pk=pk)
        except Song.DoesNotExist:
            return Response(
                {'detail': 'Song not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        lyrics = SongLyricLine.objects.filter(song=song).order_by('timestamp')

        return Response({
            'song_id': song.id,
            'song_title': song.title,
            'artist': song.artist.name,
            'duration': song.duration,
            'lyrics': LyricLineSerializer(lyrics, many=True).data,
        })


class GenreListView(GenericAPIView):
    """
    GET /api/genres/

    List all genres with their song counts, ordered by popularity.
    """
    permission_classes = [AllowAny]

    def get(self, request):
        genres = (
            Song.objects
            .values('genre')
            .annotate(count=Count('id'))
            .order_by('-count')
        )

        results = [
            {'name': g['genre'], 'count': g['count']}
            for g in genres
            if g['genre']  # Skip empty genre values
        ]

        serializer = GenreSerializer(results, many=True)
        return Response(serializer.data)


class ExternalSearchView(GenericAPIView):
    """
    GET /api/search/?q=...

    Broker search endpoint that queries:
    1. Local database
    2. MusicBrainz API
    3. LRCLIB (checks lyrics availability)

    Results are merged and deduplicated, with local matches prioritized.
    """
    permission_classes = [AllowAny]

    def get(self, request):
        query = request.query_params.get('q', '').strip()
        if not query:
            return Response(
                {'detail': 'Search query parameter "q" is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        results = []

        # 1. Search local database first
        local_songs = Song.objects.select_related('artist').filter(
            Q(title__icontains=query) |
            Q(artist__name__icontains=query)
        )[:20]

        for song in local_songs:
            results.append({
                'source': 'local',
                'mbid': song.musicbrainz_id,
                'title': song.title,
                'artist': song.artist.name,
                'duration': song.duration,
                'cover_url': request.build_absolute_uri(
                    f'{self._media_url()}{song.cover_key}'
                ) if song.cover_key else '',
                'has_synced_lyrics': song.lyrics.exists(),
                'local_id': song.id,
                'license': song.license,
            })

        # 2. Search MusicBrainz for additional results
        try:
            from .services import musicbrainz as mb_service
            from .services import coverart as ca_service

            mb_results = mb_service.search_recordings(query, limit=10)

            # Track MBIDs already in local results to avoid duplicates
            local_mbids = {r['mbid'] for r in results if r['mbid']}

            for rec in mb_results:
                if rec['mbid'] in local_mbids:
                    continue

                # Try to get cover art
                cover_url = ''
                if rec.get('release_mbid'):
                    cover_url = ca_service.get_cover_art_front(rec['release_mbid']) or ''

                results.append({
                    'source': 'musicbrainz',
                    'mbid': rec['mbid'],
                    'title': rec['title'],
                    'artist': rec['artist'],
                    'duration': rec['duration'],
                    'cover_url': cover_url,
                    'has_synced_lyrics': False,
                    'local_id': None,
                    'license': 'CC0 (metadata only)',
                })

        except Exception as e:
            logger.warning(f"MusicBrainz search failed: {e}")

        # 3. Check LRCLIB for lyrics availability
        try:
            from .services import lrclib as lrc_service
            lrc_results = lrc_service.search_lyrics(query)

            # Mark which results have synced lyrics available
            for lrc_item in lrc_results:
                if lrc_item.get('has_synced'):
                    # Try to match with existing results
                    for result in results:
                        if (
                            lrc_item['name'].lower() in result['title'].lower() or
                            result['title'].lower() in lrc_item['name'].lower()
                        ) and (
                            lrc_item['artist'].lower() in result['artist'].lower() or
                            result['artist'].lower() in lrc_item['artist'].lower()
                        ):
                            result['has_synced_lyrics'] = True
                            break

        except Exception as e:
            logger.warning(f"LRCLIB search failed: {e}")

        serializer = ExternalSearchResultSerializer(results, many=True)
        return Response(serializer.data)

    def _media_url(self):
        from django.conf import settings
        return settings.MEDIA_URL


class FetchLyricsView(GenericAPIView):
    """
    POST /api/songs/{id}/fetch-lyrics/

    Fetches synced lyrics from LRCLIB for a song and stores them
    in the database. Admin-only or for songs with no existing lyrics.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        try:
            song = Song.objects.select_related('artist').get(pk=pk)
        except Song.DoesNotExist:
            return Response(
                {'detail': 'Song not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Fetch from LRCLIB
        from .services import lrclib as lrc_service
        from .lrc_parser import parse_lrc

        lyrics_data = lrc_service.get_lyrics(
            track_name=song.title,
            artist_name=song.artist.name,
            duration=song.duration,
        )

        if not lyrics_data:
            return Response(
                {'detail': 'No synced lyrics found on LRCLIB for this song.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        synced_lrc = lyrics_data.get('synced_lyrics', '')
        if not synced_lrc:
            return Response(
                {'detail': 'Only plain lyrics available (no synced timing).'},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Parse LRC and save to database
        parsed_lines = parse_lrc(synced_lrc)

        if not parsed_lines:
            return Response(
                {'detail': 'Failed to parse LRC content.'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

        # Clear existing lyrics for this song
        SongLyricLine.objects.filter(song=song).delete()

        # Create new lyric lines
        lyric_objects = [
            SongLyricLine(
                song=song,
                timestamp=line['timestamp'],
                end_timestamp=line.get('end_timestamp', 0),
                text=line['text'],
                words=line.get('words'),
            )
            for line in parsed_lines
        ]
        SongLyricLine.objects.bulk_create(lyric_objects)

        return Response({
            'detail': f'Successfully imported {len(lyric_objects)} lyric lines.',
            'song_id': song.id,
            'lines_count': len(lyric_objects),
        })
