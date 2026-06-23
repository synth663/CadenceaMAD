"""
Cover Art Archive API Client
==============================
Fetches album cover art using MusicBrainz release MBIDs.

API docs: https://musicbrainz.org/doc/Cover_Art_Archive/API
Free to use, no authentication required.
"""

import logging
import requests
from django.conf import settings

logger = logging.getLogger(__name__)


def _get_config():
    return settings.EXTERNAL_APIS['COVER_ART_ARCHIVE']


def get_cover_art_url(release_mbid: str, size: str = '500') -> str | None:
    """
    Get the front cover art URL for a MusicBrainz release.

    Args:
        release_mbid: MusicBrainz Release MBID
        size: Image size — '250', '500', or '1200'

    Returns:
        Direct image URL string, or None if no cover found.
    """
    if not release_mbid:
        return None

    config = _get_config()
    url = f"{config['BASE_URL']}/release/{release_mbid}"

    try:
        response = requests.get(url, timeout=10, headers={
            'Accept': 'application/json',
        })
        response.raise_for_status()
        data = response.json()

        # Find front cover
        images = data.get('images', [])
        for img in images:
            if img.get('front', False):
                thumbnails = img.get('thumbnails', {})
                # Prefer requested size, fallback to any available
                if size in thumbnails:
                    return thumbnails[size]
                elif 'large' in thumbnails:
                    return thumbnails['large']
                elif 'small' in thumbnails:
                    return thumbnails['small']
                else:
                    return img.get('image', '')

        # No front cover found, try first image
        if images:
            return images[0].get('image', '')

        return None

    except requests.RequestException as e:
        logger.warning(f"Cover Art Archive error for release {release_mbid}: {e}")
        return None


def get_cover_art_front(release_mbid: str) -> str | None:
    """
    Get the direct redirect URL for the front cover (simpler endpoint).

    This returns a redirect URL to the actual image.
    Use this for embedding in API responses.
    """
    if not release_mbid:
        return None

    config = _get_config()
    # The /front endpoint redirects to the image
    url = f"{config['BASE_URL']}/release/{release_mbid}/front/500"

    try:
        # Don't follow redirect — just get the redirect URL
        response = requests.head(url, timeout=10, allow_redirects=False)
        if response.status_code in (301, 302, 307):
            return response.headers.get('Location', '')
        elif response.status_code == 200:
            return url
        return None
    except requests.RequestException as e:
        logger.warning(f"Cover Art Archive front error for release {release_mbid}: {e}")
        return None
