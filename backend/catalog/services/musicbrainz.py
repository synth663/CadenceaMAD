"""
MusicBrainz API Client
========================
Searches the MusicBrainz open music encyclopedia for canonical song metadata.

API docs: https://musicbrainz.org/doc/MusicBrainz_API
Rate limit: 1 request/second, requires descriptive User-Agent.
Data license: CC0 (public domain).
"""

import time
import logging
import requests
from django.conf import settings

logger = logging.getLogger(__name__)

_last_request_time = 0.0


def _get_config():
    return settings.EXTERNAL_APIS['MUSICBRAINZ']


def _rate_limit():
    """Enforce 1 request/second rate limit per MusicBrainz policy."""
    global _last_request_time
    config = _get_config()
    elapsed = time.time() - _last_request_time
    if elapsed < config['RATE_LIMIT']:
        time.sleep(config['RATE_LIMIT'] - elapsed)
    _last_request_time = time.time()


def _make_request(endpoint: str, params: dict) -> dict | None:
    """Make a rate-limited GET request to the MusicBrainz API."""
    config = _get_config()
    _rate_limit()

    url = f"{config['BASE_URL']}/{endpoint}"
    params['fmt'] = 'json'

    headers = {
        'User-Agent': config['USER_AGENT'],
        'Accept': 'application/json',
    }

    try:
        response = requests.get(url, params=params, headers=headers, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        logger.error(f"MusicBrainz API error: {e}")
        return None


def search_recordings(query: str, limit: int = 25) -> list[dict]:
    """
    Search MusicBrainz for recordings matching a query.

    Args:
        query: Search string (song title, artist, etc.)
        limit: Max results (default 25, max 100)

    Returns:
        List of recording dicts with keys:
            mbid, title, artist, duration_ms, isrc, release_mbid
    """
    data = _make_request('recording', {
        'query': query,
        'limit': min(limit, 100),
    })

    if not data or 'recordings' not in data:
        return []

    results = []
    for rec in data['recordings']:
        # Extract primary artist
        artist_name = ''
        artist_mbid = ''
        if 'artist-credit' in rec:
            credits = rec['artist-credit']
            if credits:
                artist_name = credits[0].get('name', '')
                artist_obj = credits[0].get('artist', {})
                artist_mbid = artist_obj.get('id', '')

        # Extract first release MBID for cover art lookup
        release_mbid = ''
        if 'releases' in rec and rec['releases']:
            release_mbid = rec['releases'][0].get('id', '')

        # Extract ISRC if available
        isrc_list = rec.get('isrcs', [])

        results.append({
            'mbid': rec.get('id', ''),
            'title': rec.get('title', ''),
            'artist': artist_name,
            'artist_mbid': artist_mbid,
            'duration_ms': rec.get('length', 0),
            'duration': (rec.get('length', 0) or 0) / 1000.0,
            'isrc': isrc_list[0] if isrc_list else '',
            'release_mbid': release_mbid,
            'score': rec.get('score', 0),
        })

    return results


def get_recording(mbid: str) -> dict | None:
    """
    Fetch full metadata for a specific recording by MBID.

    Args:
        mbid: MusicBrainz Recording MBID (36-char UUID string)

    Returns:
        Dict with full recording metadata, or None if not found.
    """
    data = _make_request(f'recording/{mbid}', {
        'inc': 'artists+releases+isrcs+genres',
    })

    if not data:
        return None

    artist_name = ''
    artist_mbid = ''
    if 'artist-credit' in data:
        credits = data['artist-credit']
        if credits:
            artist_name = credits[0].get('name', '')
            artist_obj = credits[0].get('artist', {})
            artist_mbid = artist_obj.get('id', '')

    release_mbid = ''
    if 'releases' in data and data['releases']:
        release_mbid = data['releases'][0].get('id', '')

    genres = [g.get('name', '') for g in data.get('genres', [])]

    return {
        'mbid': data.get('id', ''),
        'title': data.get('title', ''),
        'artist': artist_name,
        'artist_mbid': artist_mbid,
        'duration_ms': data.get('length', 0),
        'duration': (data.get('length', 0) or 0) / 1000.0,
        'release_mbid': release_mbid,
        'genres': genres,
        'isrcs': data.get('isrcs', []),
    }


def search_artists(query: str, limit: int = 10) -> list[dict]:
    """
    Search MusicBrainz for artists matching a query.

    Returns:
        List of artist dicts with keys: mbid, name, type, country, disambiguation
    """
    data = _make_request('artist', {
        'query': query,
        'limit': min(limit, 100),
    })

    if not data or 'artists' not in data:
        return []

    return [
        {
            'mbid': artist.get('id', ''),
            'name': artist.get('name', ''),
            'type': artist.get('type', ''),
            'country': artist.get('country', ''),
            'disambiguation': artist.get('disambiguation', ''),
        }
        for artist in data['artists']
    ]
