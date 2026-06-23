"""
Catalog Admin Configuration
=============================
Rich admin interface for managing the song catalog.
Supports uploading cover art, instrumentals, vocal references, and LRC files.
Auto-parses LRC files into SongLyricLine entries on save.
"""

import os
from django.contrib import admin
from django.conf import settings
from .models import Artist, Song, SongLyricLine


class SongLyricLineInline(admin.TabularInline):
    """Inline display of lyric lines within the Song admin."""
    model = SongLyricLine
    extra = 0
    fields = ('timestamp', 'end_timestamp', 'text')
    ordering = ('timestamp',)
    readonly_fields = ('timestamp', 'end_timestamp', 'text')

    def has_add_permission(self, request, obj=None):
        # Lyrics are auto-generated from LRC files
        return True

    def has_change_permission(self, request, obj=None):
        return True


class SongInline(admin.TabularInline):
    """Inline display of songs within the Artist admin."""
    model = Song
    extra = 0
    fields = ('title', 'genre', 'duration', 'plays')
    readonly_fields = ('plays',)
    show_change_link = True


@admin.register(Artist)
class ArtistAdmin(admin.ModelAdmin):
    list_display = ('name', 'musicbrainz_id', 'song_count')
    search_fields = ('name',)
    inlines = [SongInline]

    def song_count(self, obj):
        return obj.songs.count()
    song_count.short_description = 'Songs'


@admin.register(Song)
class SongAdmin(admin.ModelAdmin):
    list_display = ('title', 'artist', 'genre', 'duration_display', 'plays', 'has_lyrics')
    list_filter = ('genre', 'language', 'commercial_allowed')
    search_fields = ('title', 'artist__name')
    readonly_fields = ('plays', 'created_at')
    inlines = [SongLyricLineInline]

    fieldsets = (
        ('Song Info', {
            'fields': ('title', 'artist', 'genre', 'language', 'duration'),
        }),
        ('Media Files', {
            'fields': ('cover_key', 'audio_key', 'vocal_ref_key', 'lrc_key'),
            'description': (
                'Enter storage paths relative to the media directory. '
                'Example: covers/midnight.jpg, instrumentals/midnight.mp3'
            ),
        }),
        ('External Linking', {
            'fields': ('musicbrainz_id', 'license', 'source_url', 'commercial_allowed'),
            'classes': ('collapse',),
        }),
        ('Stats', {
            'fields': ('plays', 'created_at'),
        }),
    )

    def duration_display(self, obj):
        """Display duration in mm:ss format."""
        if not obj.duration:
            return '—'
        mins = int(obj.duration // 60)
        secs = int(obj.duration % 60)
        return f'{mins}:{secs:02d}'
    duration_display.short_description = 'Duration'

    def has_lyrics(self, obj):
        return obj.lyrics.exists()
    has_lyrics.boolean = True
    has_lyrics.short_description = 'Lyrics'

    def save_model(self, request, obj, form, change):
        """Override save to auto-parse LRC file when lrc_key is set."""
        super().save_model(request, obj, form, change)

        # If lrc_key was changed/set, try to parse the LRC file
        if obj.lrc_key:
            self._parse_and_import_lrc(obj)

    def _parse_and_import_lrc(self, song):
        """
        Parse an LRC file from the media directory and create SongLyricLine entries.
        """
        from .lrc_parser import parse_lrc

        lrc_path = os.path.join(settings.MEDIA_ROOT, song.lrc_key)

        if not os.path.exists(lrc_path):
            return

        try:
            with open(lrc_path, 'r', encoding='utf-8') as f:
                lrc_content = f.read()

            parsed_lines = parse_lrc(lrc_content)

            if not parsed_lines:
                return

            # Clear existing lyrics
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

        except Exception as e:
            import logging
            logging.getLogger(__name__).error(
                f"Failed to parse LRC for song {song.id}: {e}"
            )


@admin.register(SongLyricLine)
class SongLyricLineAdmin(admin.ModelAdmin):
    list_display = ('song', 'timestamp', 'text_preview')
    list_filter = ('song',)
    ordering = ('song', 'timestamp')

    def text_preview(self, obj):
        return obj.text[:80] + '...' if len(obj.text) > 80 else obj.text
    text_preview.short_description = 'Text'
