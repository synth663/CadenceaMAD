"""
Jamendo API Client
====================
Searches the Jamendo independent music catalog for CC-licensed audio tracks.

API docs: https://developer.jamendo.com/v3.0/docs
Requires client_id. Free for non-commercial use.
"""

import logging
import requests
from django.conf import settings

logger = logging.getLogger(__name__)


def _get_config():
    return settings.EXTERNAL_APIS['JAMENDO']


def _is_configured() -> bool:
    """Check if Jamendo client_id is configured."""
    config = _get_config()
    return bool(config.get('CLIENT_ID'))


def search_tracks(
    query: str,
    limit: int = 20,
    include_audio: bool = True,
) -> list[dict]:
    """
    Search Jamendo for CC-licensed audio tracks.

    Args:
        query: Search string
        limit: Max results (default 20)
        include_audio: Include streaming audio URLs

    Returns:
        List of track dicts with keys:
            id, name, artist_name, album_name, duration,
            audio_url, audio_download_url, license, image, shareurl
    """
    config = _get_config()

    if not _is_configured():
        logger.warning("Jamendo client_id not configured. Skipping search.")
        return []

    url = f"{config['BASE_URL']}/tracks"

    params = {
        'client_id': config['CLIENT_ID'],
        'format': 'json',
        'limit': min(limit, 200),
        'search': query,
        'include': 'musicinfo+licenses+stats',
    }

    if include_audio:
        params['audioformat'] = 'mp32'  # MP3 320kbps

    try:
        response = requests.get(url, params=params, timeout=15)
        response.raise_for_status()
        data = response.json()

        if data.get('headers', {}).get('status') != 'success':
            logger.warning(f"Jamendo search returned non-success status")
            return []

        results = []
        for track in data.get('results', []):
            license_url = track.get('license_ccurl', '')

            results.append({
                'id': track.get('id', ''),
                'name': track.get('name', ''),
                'artist_name': track.get('artist_name', ''),
                'album_name': track.get('album_name', ''),
                'duration': track.get('duration', 0),
                'audio_url': track.get('audio', ''),
                'audio_download_url': track.get('audiodownload', ''),
                'license': _parse_cc_license(license_url),
                'license_url': license_url,
                'image': track.get('image', ''),
                'shareurl': track.get('shareurl', ''),
                'commercial_allowed': 'nc' not in license_url.lower() if license_url else False,
            })

        return results

    except requests.RequestException as e:
        logger.error(f"Jamendo search error for '{query}': {e}")
        return []


def get_track(track_id: str) -> dict | None:
    """
    Fetch a specific Jamendo track by ID.

    Args:
        track_id: Jamendo track ID

    Returns:
        Track dict or None.
    """
    config = _get_config()

    if not _is_configured():
        return None

    url = f"{config['BASE_URL']}/tracks"

    try:
        response = requests.get(url, params={
            'client_id': config['CLIENT_ID'],
            'format': 'json',
            'id': track_id,
            'include': 'musicinfo+licenses+stats',
            'audioformat': 'mp32',
        }, timeout=15)

        response.raise_for_status()
        data = response.json()

        results = data.get('results', [])
        if not results:
            return None

        track = results[0]
        license_url = track.get('license_ccurl', '')

        return {
            'id': track.get('id', ''),
            'name': track.get('name', ''),
            'artist_name': track.get('artist_name', ''),
            'album_name': track.get('album_name', ''),
            'duration': track.get('duration', 0),
            'audio_url': track.get('audio', ''),
            'audio_download_url': track.get('audiodownload', ''),
            'license': _parse_cc_license(license_url),
            'license_url': license_url,
            'image': track.get('image', ''),
            'commercial_allowed': 'nc' not in license_url.lower() if license_url else False,
        }

    except requests.RequestException as e:
        logger.error(f"Jamendo get track error for '{track_id}': {e}")
        return None


def _parse_cc_license(license_url: str) -> str:
    """Parse a Creative Commons URL into a short license name."""
    if not license_url:
        return 'Unknown'

    url_lower = license_url.lower()
    if 'by-nc-sa' in url_lower:
        return 'CC BY-NC-SA'
    elif 'by-nc-nd' in url_lower:
        return 'CC BY-NC-ND'
    elif 'by-nc' in url_lower:
        return 'CC BY-NC'
    elif 'by-sa' in url_lower:
        return 'CC BY-SA'
    elif 'by-nd' in url_lower:
        return 'CC BY-ND'
    elif 'by' in url_lower:
        return 'CC BY'
    elif 'publicdomain' in url_lower or 'cc0' in url_lower:
        return 'CC0'
    return 'CC'
