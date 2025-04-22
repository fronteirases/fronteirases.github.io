# YouTube Subtitle Downloader

A simple Python script to download subtitles from YouTube videos and playlists.

## Installation

1. Make sure you have Python 3.6+ installed
2. Create and activate a virtual environment:
```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Linux/Mac:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate
```
3. Install the required dependencies:
```bash
pip install -r requirements.txt
```

To deactivate the virtual environment when you're done:
```bash
deactivate
```

## Usage

You can use the script in three ways:

1. Download subtitles for a single video:
```bash
python subtitle_downloader.py "https://youtu.be/VIDEO_ID"
```

2. Download subtitles for an entire playlist:
```bash
python subtitle_downloader.py --playlist "https://www.youtube.com/playlist?list=PLAYLIST_ID"
```

3. Save subtitles to a specific file:
```bash
python subtitle_downloader.py "https://youtu.be/VIDEO_ID" output.txt
```

## Features

- Supports various YouTube URL formats (youtube.com, youtu.be, shorts)
- Automatically detects available subtitles
- Formats subtitles with timestamps
- Can save to file or print to console
- No authentication required for public videos
- Downloads subtitles for entire playlists
- Automatically generates filenames using video publication date and title
- Handles multiple languages (prefers English, then Portuguese, then any available)
- Provides detailed progress and error reporting

## Example

1. Download subtitles for a single video:
```bash
python subtitle_downloader.py "https://youtu.be/JnM7bDqWR18"
```
This will download the subtitles and save them to a file named `YYYY-MM-DD-VIDEO_TITLE.srt`.

2. Download subtitles for a playlist:
```bash
python subtitle_downloader.py --playlist "https://www.youtube.com/playlist?list=PLAYLIST_ID"
```
This will download subtitles for all videos in the playlist, saving each to a separate file named `YYYY-MM-DD-VIDEO_TITLE.srt`.

## Output Format

Subtitles are saved in SRT format with the following naming convention:
```
YYYY-MM-DD-VIDEO_TITLE.srt
```

For example:
```
2020-09-09-Diego_Aranha_Professor_na_Universidade_de_Aarhus_Dinamarca_NaoAoFascismo.srt
```

## Requirements

- Python 3.6+
- youtube_transcript_api
- pytube
- requests

