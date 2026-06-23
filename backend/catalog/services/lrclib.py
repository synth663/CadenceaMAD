"""
LRCLIB API Client
==================
Fetches synced (timed) lyrics from the LRCLIB open lyrics service.

API docs: https://lrclib.net/docs
Free, open-source, no authentication required.
Critical for karaoke-style time-synced lyrics display.
"""

import logging
import requests
from django.conf import settings

logger = logging.getLogger(__name__)


def _get_config():
    return settings.EXTERNAL_APIS['LRCLIB']


def get_lyrics(
    track_name: str,
    artist_name: str,
    album_name: str = '',
    duration: float = 0.0,
) -> dict | None:
    """
    Fetch synced lyrics for a specific track from LRCLIB.

    Args:
        track_name: Song title
        artist_name: Artist name
        album_name: Album name (optional, improves matching)
        duration: Track duration in seconds (optional, improves matching)

    Returns:
        Dict with keys:
            id, name, artist, album, duration,
            plain_lyrics (str), synced_lyrics (LRC string)
        Or None if not found.
    """
    config = _get_config()
    url = f"{config['BASE_URL']}/api/get"

    params = {
        'track_name': track_name,
        'artist_name': artist_name,
    }
    if album_name:
        params['album_name'] = album_name
    if duration > 0:
        params['duration'] = int(duration)

    try:
        response = requests.get(url, params=params, timeout=10, headers={
            'User-Agent': 'Cadencea/1.0.0',
        })

        if response.status_code == 404:
            logger.info(f"LRCLIB: No lyrics found for '{track_name}' by '{artist_name}'")
            return None

        response.raise_for_status()
        data = response.json()

        return {
            'id': data.get('id'),
            'name': data.get('trackName', track_name),
            'artist': data.get('artistName', artist_name),
            'album': data.get('albumName', ''),
            'duration': data.get('duration', 0),
            'plain_lyrics': data.get('plainLyrics', ''),
            'synced_lyrics': data.get('syncedLyrics', ''),
            'instrumental': data.get('instrumental', False),
        }

    except requests.RequestException as e:
        logger.error(f"LRCLIB API error for '{track_name}': {e}")
        return None


def search_lyrics(query: str) -> list[dict]:
    """
    Search LRCLIB for tracks with available lyrics.

    Args:
        query: Search string (song title, artist, etc.)

    Returns:
        List of matching track dicts.
    """
    config = _get_config()
    url = f"{config['BASE_URL']}/api/search"

    try:
        response = requests.get(
            url,
            params={'q': query},
            timeout=10,
            headers={'User-Agent': 'Cadencea/1.0.0'},
        )
        response.raise_for_status()
        data = response.json()

        results = []
        for item in data:
            results.append({
                'id': item.get('id'),
                'name': item.get('trackName', ''),
                'artist': item.get('artistName', ''),
                'album': item.get('albumName', ''),
                'duration': item.get('duration', 0),
                'has_synced': bool(item.get('syncedLyrics')),
                'has_plain': bool(item.get('plainLyrics')),
                'instrumental': item.get('instrumental', False),
            })

        return results

    except requests.RequestException as e:
        logger.error(f"LRCLIB search error for '{query}': {e}")
        return []


def get_lyrics_by_id(lrclib_id: int) -> dict | None:
    """
    Fetch lyrics by LRCLIB track ID.

    Args:
        lrclib_id: LRCLIB internal track ID

    Returns:
        Same format as get_lyrics(), or None.
    """
    config = _get_config()
    url = f"{config['BASE_URL']}/api/get/{lrclib_id}"

    try:
        response = requests.get(url, timeout=10, headers={
            'User-Agent': 'Cadencea/1.0.0',
        })

        if response.status_code == 404:
            return None

        response.raise_for_status()
        data = response.json()

        return {
            'id': data.get('id'),
            'name': data.get('trackName', ''),
            'artist': data.get('artistName', ''),
            'album': data.get('albumName', ''),
            'duration': data.get('duration', 0),
            'plain_lyrics': data.get('plainLyrics', ''),
            'synced_lyrics': data.get('syncedLyrics', ''),
            'instrumental': data.get('instrumental', False),
        }

    except requests.RequestException as e:
        logger.error(f"LRCLIB get by ID error: {e}")
        return None
