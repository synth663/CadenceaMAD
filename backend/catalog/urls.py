"""
Catalog URL Configuration
==========================
All song/genre/search endpoints mounted under /api/ prefix.
"""

from django.urls import path
from .views import (
    SongListView,
    SongDetailView,
    SongLyricsView,
    GenreListView,
    ExternalSearchView,
    FetchLyricsView,
)

urlpatterns = [
    # Song catalog
    path('songs/', SongListView.as_view(), name='song-list'),
    path('songs/<int:pk>/', SongDetailView.as_view(), name='song-detail'),
    path('songs/<int:pk>/lyrics/', SongLyricsView.as_view(), name='song-lyrics'),
    path('songs/<int:pk>/fetch-lyrics/', FetchLyricsView.as_view(), name='song-fetch-lyrics'),

    # Genres
    path('genres/', GenreListView.as_view(), name='genre-list'),

    # External search broker
    path('search/', ExternalSearchView.as_view(), name='external-search'),
]
