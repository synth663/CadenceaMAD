"""
Catalog Tests
==============
Tests for LRC parser, song endpoints, and genre listing.
"""

from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status

from authentication.models import User
from catalog.models import Artist, Song, SongLyricLine
from catalog.lrc_parser import parse_lrc


class LrcParserTests(TestCase):
    """Test the LRC timestamp parser."""

    def test_standard_lrc(self):
        lrc = """[00:01.25] Walking down the midnight street
[00:05.40] No one else but you and me
[00:10.00] Under the stars so bright"""
        result = parse_lrc(lrc)
        self.assertEqual(len(result), 3)
        self.assertAlmostEqual(result[0]['timestamp'], 1.25, places=2)
        self.assertEqual(result[0]['text'], 'Walking down the midnight street')
        self.assertAlmostEqual(result[1]['timestamp'], 5.40, places=2)

    def test_end_timestamps_calculated(self):
        lrc = "[00:01.00] First line\n[00:05.00] Second line"
        result = parse_lrc(lrc)
        self.assertAlmostEqual(result[0]['end_timestamp'], 5.0, places=2)

    def test_enhanced_lrc_with_word_timing(self):
        lrc = "[00:01.00] <00:01.00>Hello <00:01.50>World"
        result = parse_lrc(lrc)
        self.assertEqual(len(result), 1)
        self.assertIsNotNone(result[0].get('words'))
        self.assertEqual(len(result[0]['words']), 2)
        self.assertEqual(result[0]['words'][0]['word'], 'Hello')
        self.assertAlmostEqual(result[0]['words'][0]['start'], 1.0, places=2)

    def test_empty_lrc(self):
        result = parse_lrc("")
        self.assertEqual(len(result), 0)

    def test_metadata_lines_skipped(self):
        lrc = """[ar:Artist Name]
[ti:Song Title]
[00:01.00] Actual lyrics here"""
        result = parse_lrc(lrc)
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]['text'], 'Actual lyrics here')

    def test_sorted_by_timestamp(self):
        lrc = "[00:05.00] Second\n[00:01.00] First"
        result = parse_lrc(lrc)
        self.assertAlmostEqual(result[0]['timestamp'], 1.0, places=2)
        self.assertAlmostEqual(result[1]['timestamp'], 5.0, places=2)


class SongEndpointTests(TestCase):
    """Test song catalog API endpoints."""

    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='songuser', email='song@cadencea.io', password='SongPass123!'
        )
        # Login
        login_response = self.client.post(
            reverse('auth-login'),
            {'email': 'song@cadencea.io', 'password': 'SongPass123!'},
            format='json',
        )
        self.token = login_response.data['tokens']['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.token}')

        # Create test data
        self.artist = Artist.objects.create(name='Test Artist', bio='Test bio')
        self.song = Song.objects.create(
            title='Test Song',
            artist=self.artist,
            genre='Pop',
            duration=180.0,
            plays=100,
        )
        SongLyricLine.objects.create(
            song=self.song, timestamp=1.0, text='First line'
        )
        SongLyricLine.objects.create(
            song=self.song, timestamp=5.0, text='Second line'
        )

    def test_song_list(self):
        response = self.client.get(reverse('song-list'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)
        self.assertEqual(response.data['results'][0]['title'], 'Test Song')

    def test_song_search(self):
        response = self.client.get(reverse('song-list'), {'q': 'Test'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)

    def test_song_search_by_artist(self):
        response = self.client.get(reverse('song-list'), {'q': 'Test Artist'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)

    def test_song_search_no_results(self):
        response = self.client.get(reverse('song-list'), {'q': 'Nonexistent'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 0)

    def test_song_genre_filter(self):
        response = self.client.get(reverse('song-list'), {'genre': 'Pop'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)

    def test_song_detail_with_lyrics(self):
        response = self.client.get(
            reverse('song-detail', kwargs={'pk': self.song.id})
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['title'], 'Test Song')
        self.assertEqual(len(response.data['lyrics']), 2)
        self.assertEqual(response.data['lyrics'][0]['text'], 'First line')

    def test_song_lyrics_endpoint(self):
        response = self.client.get(
            reverse('song-lyrics', kwargs={'pk': self.song.id})
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['song_id'], self.song.id)
        self.assertEqual(len(response.data['lyrics']), 2)

    def test_genre_list(self):
        response = self.client.get(reverse('genre-list'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data) >= 1)
        self.assertEqual(response.data[0]['name'], 'Pop')
        self.assertEqual(response.data[0]['count'], 1)

    def test_unauthenticated_access_denied(self):
        self.client.credentials()  # Remove auth
        response = self.client.get(reverse('song-list'))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
