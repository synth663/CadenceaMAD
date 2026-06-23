import os
from django.core.management.base import BaseCommand
from django.conf import settings
from catalog.models import Artist, Song, SongLyricLine
from catalog.lrc_parser import parse_lrc

MAPPINGS = [
    {
        'artist': 'ABBA',
        'title': 'Dancing Queen',
        'instrumental': 'instrumentals/ABBA - Dancing Queen (Karaoke Version).mp3',
        'cover': 'covers/Arrival.jpg',
        'lrc': 'lyrics/Abba - Dancing Queen.lrc'
    },
    {
        'artist': 'Arijit Singh, Alka Yagnik',
        'title': 'Agar Tum Saath Ho',
        'instrumental': 'instrumentals/Alka Yagnik, Arijit Singh - Agar Tum Saath Ho(Karaoke Version).mp3',
        'cover': 'covers/tamasha.jpg',
        'lrc': 'lyrics/Alka Yagnik & Arijit Singh - Agar Tum Saath Ho (From - Tamasha).lrc'
    },
    {
        'artist': 'Arctic Monkeys',
        'title': 'Do I Wanna Know',
        'instrumental': 'instrumentals/Arctic Monkeys - Do I Wanna Know (Karaoke).mp3',
        'cover': 'covers/ArcticMonkeys.jpg',
        'lrc': 'lyrics/Arctic Monkeys - Do I Wanna Know.lrc'
    },
    {
        'artist': 'Arijit Singh',
        'title': 'Tum Hi Ho',
        'instrumental': 'instrumentals/Arijit SIngh - Tum Hi Ho(Karaoke Version).mp3',
        'cover': 'covers/Aashiqui2.jpg',
        'lrc': 'lyrics/Arjit Singh_Tum Hi Ho.lrc'
    },
    {
        'artist': 'Avicii',
        'title': 'Waiting For Love',
        'instrumental': 'instrumentals/Avicii - Waiting For Love (Karaoke).mp3',
        'cover': 'covers/Stories.jpg',
        'lrc': 'lyrics/Avicii - Waiting For Love.lrc'
    },
    {
        'artist': 'Billy Joel',
        'title': 'Vienna',
        'instrumental': 'instrumentals/Billy Joel - Vienna (Karaoke Version).mp3',
        'cover': 'covers/TheStranger.png',
        'lrc': 'lyrics/Billy Joel - Vienna.lrc'
    },
    {
        'artist': 'Carly Rae Jepsen',
        'title': 'Call Me Maybe',
        'instrumental': 'instrumentals/Carly Rae Jepsen - Call Me Maybe.mp3',
        'cover': 'covers/Kiss.jpg',
        'lrc': 'lyrics/Carly Rae Jepsen - Call Me Maybe.lrc'
    },
    {
        'artist': 'Enrique Iglesias',
        'title': 'Hero',
        'instrumental': 'instrumentals/Enrique Inglesias - Hero (Karaoke Version).mp3',
        'cover': 'covers/Escape.jpg',
        'lrc': 'lyrics/Enrique Iglesias - Hero.lrc'
    },
    {
        'artist': 'Florence + The Machine',
        'title': 'Dog Days Are Over',
        'instrumental': 'instrumentals/Florence + The Machines - Dog Days Are Over (Karaoke).mp3',
        'cover': 'covers/Lungs.jpg',
        'lrc': 'lyrics/Florence and the Machine - Dog Days Are Over.lrc'
    },
    {
        'artist': 'KK',
        'title': 'Ajab Si',
        'instrumental': 'instrumentals/KK - Ajab Si (KARAOKE).mp3',
        'cover': 'covers/OmShantiOm.jpg',
        'lrc': 'lyrics/KK & Vishal & Shekhar - Ajab Si.lrc'
    },
    {
        'artist': 'The Notorious B.I.G.',
        'title': 'Hypnotize',
        'instrumental': 'instrumentals/Notorious B.I.G. - Hypnotize (Karaoke).mp3',
        'cover': 'covers/Hypnotize.jpg',
        'lrc': 'lyrics/The Notorious B.I.G. - Hypnotize.lrc'
    },
    {
        'artist': 'Queen',
        'title': 'Bohemian Rhapsody',
        'instrumental': 'instrumentals/Queen - Bohemian Rhapsody (Karaoke).mp3',
        'cover': 'covers/ANightAtTheOpera.jpg',
        'lrc': 'lyrics/Queen - Bohemian Rhapsody.lrc'
    },
    {
        'artist': 'Radiohead',
        'title': 'Creep',
        'instrumental': 'instrumentals/Radiohead - Creep (Karaoke Version).mp3',
        'cover': 'covers/PabloHoney.jpg',
        'lrc': 'lyrics/Creep - Radiohead.lrc'
    },
    {
        'artist': 'Shilpa Rao, Sreerama Chandra',
        'title': 'Subhanallah',
        'instrumental': 'instrumentals/Shilpa Rao, Sreerama Chandra - Subhanallah(Karaoke Version).mp3',
        'cover': 'covers/YJHD.jpg',
        'lrc': 'lyrics/Sreeram & Shilpa Rao - Subhanallah (From - Yeh Jawaani Hai Deewani).lrc'
    },
    {
        'artist': 'Shreya Ghoshal',
        'title': 'Bahara',
        'instrumental': 'instrumentals/Shreya Ghoshal - Bahara(Karaoke Version).mp3',
        'cover': 'covers/IHateLuvStorys.jpg',
        'lrc': 'lyrics/Vishal & Shekhar, Shreya Ghoshal & Sona Mohapatra - Bahara (From - I Hate Luv Storys).lrc'
    },
    {
        'artist': 'Shreya Ghoshal, Ami Mishra',
        'title': 'Hasi (Female Version)',
        'instrumental': 'instrumentals/Shreya Ghoshal - Hasi-Female(Karaoke Version).mp3',
        'cover': 'covers/Hamari-Adhuri-Kahani.jpg',
        'lrc': 'lyrics/Ami Mishra & Shreya Ghoshal - Hasi (Female Version).lrc'
    },
    {
        'artist': 'Taylor Swift',
        'title': 'exile',
        'instrumental': 'instrumentals/Taylor Swift - exile (Karaoke).mp3',
        'cover': 'covers/Folklore.jpg',
        'lrc': 'lyrics/Taylor Swift - exile.lrc'
    },
    {
        'artist': 'The Goo Goo Dolls',
        'title': 'Iris',
        'instrumental': 'instrumentals/The Goo Goo Dolls - Iris (Karaoke).mp3',
        'cover': 'covers/DizzyUpTheGirl.jpg',
        'lrc': 'lyrics/Goo Goo Dolls - Iris.lrc'
    },
    {
        'artist': 'The Weeknd',
        'title': 'Die For You',
        'instrumental': 'instrumentals/The Weeknd - Die For You (Karaoke Version).mp3',
        'cover': 'covers/Starboy.jpg',
        'lrc': 'lyrics/The Weeknd - Die For You.lrc'
    },
    {
        'artist': 'Tracy Chapman',
        'title': 'Fast Car',
        'instrumental': 'instrumentals/Tracy Chapman - Fast Car (Karaoke Version).mp3',
        'cover': 'covers/TracyChapman.jpg',
        'lrc': 'lyrics/Tracy Chapman - Fast Car.lrc'
    }
]

class Command(BaseCommand):
    help = 'Seeds the catalog database using the provided media files in covers/, instrumentals/, and lyrics/ directories.'

    def handle(self, *args, **kwargs):
        self.stdout.write('Clearing existing catalog data...')
        SongLyricLine.objects.all().delete()
        Song.objects.all().delete()
        Artist.objects.all().delete()

        self.stdout.write('Seeding database with provided media files...')
        
        media_root = settings.MEDIA_ROOT

        for mapping in MAPPINGS:
            artist, _ = Artist.objects.get_or_create(name=mapping['artist'])

            # Validate files exist
            inst_path = os.path.join(media_root, mapping['instrumental'])
            cover_path = os.path.join(media_root, mapping['cover'])
            lrc_path = os.path.join(media_root, mapping['lrc'])

            if not os.path.exists(inst_path):
                self.stdout.write(self.style.ERROR(f"Missing instrumental: {inst_path}"))
                continue
            if not os.path.exists(cover_path):
                self.stdout.write(self.style.ERROR(f"Missing cover: {cover_path}"))
                continue
            if not os.path.exists(lrc_path):
                self.stdout.write(self.style.ERROR(f"Missing LRC: {lrc_path}"))
                continue

            # Read lyrics
            with open(lrc_path, 'r', encoding='utf-8') as f:
                lrc_content = f.read()

            song = Song.objects.create(
                title=mapping['title'],
                artist=artist,
                genre='Unknown',  # Defaulting as it's not provided in filenames
                audio_key=mapping['instrumental'],
                cover_key=mapping['cover'],
                lrc_key=mapping['lrc'],
                commercial_allowed=False,
            )
            
            parsed_lyrics = parse_lrc(lrc_content)
            
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
            
            SongLyricLine.objects.bulk_create(lyric_lines)
            self.stdout.write(f'Created song: {song.title} by {artist.name} with {len(lyric_lines)} lyric lines.')

        self.stdout.write(self.style.SUCCESS('Successfully seeded the catalog database from media files!'))
