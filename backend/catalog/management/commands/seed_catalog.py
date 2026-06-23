from django.core.management.base import BaseCommand
from catalog.models import Artist, Song, SongLyricLine
from catalog.lrc_parser import parse_lrc

class Command(BaseCommand):
    help = 'Seeds the catalog database with artists, karaoke songs, and parsed LRC lyrics.'

    def handle(self, *args, **kwargs):
        self.stdout.write('Clearing existing catalog data...')
        SongLyricLine.objects.all().delete()
        Song.objects.all().delete()
        Artist.objects.all().delete()

        self.stdout.write('Seeding artists...')
        adele = Artist.objects.create(name='Adele', bio='British singer-songwriter known for her soulful voice.')
        beatles = Artist.objects.create(name='The Beatles', bio='Legendary English rock band formed in Liverpool.')
        queen = Artist.objects.create(name='Queen', bio='British rock band formed in London in 1970.')

        songs_data = [
            {
                'title': 'Someone Like You (Karaoke Version)',
                'artist': adele,
                'genre': 'Pop',
                'duration': 285.0,
                'lrc': """[00:01.00] I heard that you're settled down
[00:05.00] That you found a girl and you're married now
[00:09.00] I heard that your dreams came true
[00:13.00] Guess she gave you things, I didn't give to you
[00:17.00] Old friend, why are you so shy?
[00:21.00] Ain't like you to hold back or hide from the light"""
            },
            {
                'title': 'Let It Be (Karaoke Version)',
                'artist': beatles,
                'genre': 'Rock',
                'duration': 243.0,
                'lrc': """[00:01.00] When I find myself in times of trouble
[00:05.00] Mother Mary comes to me
[00:08.00] Speaking words of wisdom, let it be
[00:15.00] And in my hour of darkness
[00:18.00] She is standing right in front of me
[00:22.00] Speaking words of wisdom, let it be
[00:28.00] Let it be, let it be
[00:32.00] Let it be, let it be
[00:35.00] Whisper words of wisdom, let it be"""
            },
            {
                'title': 'Bohemian Rhapsody (Karaoke Version)',
                'artist': queen,
                'genre': 'Rock',
                'duration': 354.0,
                'lrc': """[00:01.00] Is this the real life?
[00:04.00] Is this just fantasy?
[00:08.00] Caught in a landslide
[00:11.00] No escape from reality
[00:15.00] Open your eyes
[00:18.00] Look up to the skies and see
[00:22.00] I'm just a poor boy, I need no sympathy
[00:28.00] Because I'm easy come, easy go
[00:31.00] Little high, little low"""
            }
        ]

        self.stdout.write('Seeding songs and lyrics...')
        for data in songs_data:
            # We use a placeholder for audio_key as the user will provide actual instrumental audio files later
            song = Song.objects.create(
                title=data['title'],
                artist=data['artist'],
                genre=data['genre'],
                duration=data['duration'],
                audio_key='placeholder_instrumental.mp3',  # Placeholder to be updated when user provides actual files
                cover_key='placeholder_cover.jpg',
                commercial_allowed=False,
            )
            
            parsed_lyrics = parse_lrc(data['lrc'])
            
            lyric_lines = []
            for line in parsed_lyrics:
                lyric_lines.append(
                    SongLyricLine(
                        song=song,
                        timestamp=line['timestamp'],
                        end_timestamp=line['end_timestamp'],
                        text=line['text'],
                        words=line.get('words')
                    )
                )
            
            # Bulk create lyric lines for efficiency
            SongLyricLine.objects.bulk_create(lyric_lines)
            self.stdout.write(f'Created song: {song.title} with {len(lyric_lines)} lyric lines.')

        self.stdout.write(self.style.SUCCESS('Successfully seeded the catalog database!'))
        self.stdout.write(self.style.WARNING('Note: Recordings were skipped as per preference. "My Recordings" page will remain empty.'))
        self.stdout.write(self.style.WARNING('Note: Songs were created with placeholder audio file paths ("placeholder_instrumental.mp3"). Please update these in the Django Admin or directly in the DB when you have the actual files.'))
