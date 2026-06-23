"""
LRC Parser
===========
Parses standard and enhanced LRC (synced lyrics) format into structured data.

Standard LRC format:
    [mm:ss.xx] Lyric text here

Enhanced LRC format (word-level timing):
    [mm:ss.xx] <mm:ss.xx>Word1 <mm:ss.xx>Word2 <mm:ss.xx>Word3

Returns a list of dicts:
    [
        {
            'timestamp': 1.25,
            'text': 'Walking down the midnight street',
            'words': [
                {'word': 'Walking', 'start': 1.25, 'end': 1.80},
                ...
            ]
        },
        ...
    ]
"""

import re
from typing import Optional


# Standard timestamp: [mm:ss.xx] or [mm:ss.xxx]
LINE_PATTERN = re.compile(
    r'\[(\d{1,3}):(\d{2})\.(\d{2,3})\]\s*(.*)'
)

# Enhanced word-level timestamp: <mm:ss.xx> or <mm:ss.xxx>
WORD_PATTERN = re.compile(
    r'<(\d{1,3}):(\d{2})\.(\d{2,3})>'
)


def _parse_timestamp(minutes: str, seconds: str, centiseconds: str) -> float:
    """Convert mm:ss.xx timestamp parts to seconds as float."""
    mins = int(minutes)
    secs = int(seconds)
    # Handle both .xx (centiseconds) and .xxx (milliseconds)
    if len(centiseconds) == 2:
        frac = int(centiseconds) / 100.0
    else:
        frac = int(centiseconds) / 1000.0
    return mins * 60.0 + secs + frac


def parse_lrc(lrc_content: str) -> list[dict]:
    """
    Parse an LRC string into a list of timestamped lyric lines.

    Supports both standard LRC and enhanced LRC with word-level timing.
    Skips metadata lines (e.g., [ar:Artist], [ti:Title]).

    Args:
        lrc_content: Raw LRC file content as string.

    Returns:
        List of dicts with 'timestamp', 'text', and optional 'words' keys.
        Sorted by timestamp ascending.
    """
    lines = []

    for raw_line in lrc_content.strip().splitlines():
        raw_line = raw_line.strip()
        if not raw_line:
            continue

        match = LINE_PATTERN.match(raw_line)
        if not match:
            continue

        minutes, seconds, centiseconds, text = match.groups()
        timestamp = _parse_timestamp(minutes, seconds, centiseconds)

        # Skip empty lyric lines
        text = text.strip()
        if not text:
            continue

        # Check for word-level timestamps in the text
        words = _parse_word_timestamps(text, timestamp)

        # Clean the text of any embedded timestamps
        clean_text = WORD_PATTERN.sub('', text).strip()

        entry = {
            'timestamp': round(timestamp, 3),
            'text': clean_text,
        }

        if words:
            entry['words'] = words

        lines.append(entry)

    # Sort by timestamp
    lines.sort(key=lambda x: x['timestamp'])

    # Calculate end_timestamp for each line (start of next line)
    for i in range(len(lines)):
        if i + 1 < len(lines):
            lines[i]['end_timestamp'] = lines[i + 1]['timestamp']
        else:
            # Last line: add 5 seconds as estimated duration
            lines[i]['end_timestamp'] = round(lines[i]['timestamp'] + 5.0, 3)

    return lines


def _parse_word_timestamps(text: str, line_start: float) -> Optional[list[dict]]:
    """
    Parse word-level timestamps from enhanced LRC text.

    Enhanced format: <mm:ss.xx>Word1 <mm:ss.xx>Word2

    Returns None if no word-level timestamps are found.
    """
    word_matches = list(WORD_PATTERN.finditer(text))
    if not word_matches:
        return None

    words = []
    for i, match in enumerate(word_matches):
        # Get the word that follows this timestamp
        start_pos = match.end()
        if i + 1 < len(word_matches):
            end_pos = word_matches[i + 1].start()
        else:
            end_pos = len(text)

        word_text = text[start_pos:end_pos].strip()
        if not word_text:
            continue

        word_start = _parse_timestamp(
            match.group(1), match.group(2), match.group(3)
        )

        # Word end = next word's start, or estimate
        if i + 1 < len(word_matches):
            next_match = word_matches[i + 1]
            word_end = _parse_timestamp(
                next_match.group(1), next_match.group(2), next_match.group(3)
            )
        else:
            # Last word: estimate end as start + 0.5s
            word_end = round(word_start + 0.5, 3)

        words.append({
            'word': word_text,
            'start': round(word_start, 3),
            'end': round(word_end, 3),
        })

    return words if words else None


def parse_lrc_file(filepath: str) -> list[dict]:
    """Convenience: read an LRC file from disk and parse it."""
    with open(filepath, 'r', encoding='utf-8') as f:
        return parse_lrc(f.read())
