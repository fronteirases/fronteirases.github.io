#!/usr/bin/env python3


# python subtitle_downloader.py "https://youtu.be/VIDEO_ID"

# python subtitle_downloader.py --playlist "https://www.youtube.com/playlist?list=PLAYLIST_ID"

from youtube_transcript_api import YouTubeTranscriptApi
from pytube import YouTube, Playlist
import sys
import re
import os
from datetime import datetime
import requests
from urllib.parse import parse_qs, urlparse
import json

def extract_video_id(url):
    """Extract video ID from various YouTube URL formats."""
    patterns = [
        r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)',
        r'youtube\.com\/shorts\/([^&\n?#]+)'
    ]
    
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    return None

def get_video_info(video_id):
    """Get video title and publish date using YouTube's API."""
    try:
        # First try to get title from oEmbed
        response = requests.get(f'https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json')
        if response.status_code == 200:
            data = response.json()
            title = data['title']
            
            # Now try to get publish date from video page
            video_page = requests.get(f'https://www.youtube.com/watch?v={video_id}')
            if video_page.status_code == 200:
                # Look for the publish date in the page content
                match = re.search(r'"publishDate":"([^"]+)"', video_page.text)
                if match:
                    publish_date = match.group(1)
                    # Convert from ISO format to YYYY-MM-DD
                    date_obj = datetime.fromisoformat(publish_date.replace('Z', '+00:00'))
                    return title, date_obj.strftime('%Y-%m-%d')
            
            return title, ""
    except:
        pass
    return f"youtube_{video_id}", ""

def format_time(seconds):
    """Convert seconds to SRT time format (HH:MM:SS,mmm)"""
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    seconds = seconds % 60
    milliseconds = int((seconds % 1) * 1000)
    seconds = int(seconds)
    return f"{hours:02d}:{minutes:02d}:{seconds:02d},{milliseconds:03d}"

def get_safe_filename(title):
    """Convert title to safe filename by replacing spaces and special chars"""
    # Replace spaces with underscores
    safe_name = title.replace(' ', '_')
    # Remove any characters that aren't alphanumeric, underscore, or hyphen
    safe_name = re.sub(r'[^\w\-]', '', safe_name)
    return safe_name

def download_subtitles_for_video(video_url, output_file=None):
    """Download subtitles for a single YouTube video."""
    video_id = extract_video_id(video_url)
    
    if not video_id:
        print(f"Error: Invalid YouTube URL: {video_url}")
        return False
    
    try:
        # Get video info
        video_title, publish_date = get_video_info(video_id)
        safe_title = get_safe_filename(video_title)
        
        # If no output file specified, use video title with date
        if not output_file:
            if publish_date:
                output_file = f"{publish_date}-{safe_title}.srt"
            else:
                output_file = f"{safe_title}.srt"
        elif not output_file.endswith('.srt'):
            # If output file specified but doesn't end with .srt, append it
            output_file = f"{os.path.splitext(output_file)[0]}.srt"
        
        # Get available transcripts
        transcript_list = YouTubeTranscriptApi.list_transcripts(video_id)
        
        # Try to get English transcript first, then Portuguese, then any available
        transcript = None
        for lang in ['en', 'pt']:
            try:
                transcript = transcript_list.find_transcript([lang])
                break
            except:
                continue
                
        if transcript is None:
            # If no preferred language found, get the first available transcript
            transcript = transcript_list.find_transcript([])
        
        # Get the transcript data
        transcript_data = transcript.fetch()
        
        # Format the subtitles in SRT format
        srt_subtitles = []
        for i, entry in enumerate(transcript_data, 1):
            start_time = format_time(entry['start'])
            end_time = format_time(entry['start'] + entry['duration'])
            
            srt_entry = f"{i}\n{start_time} --> {end_time}\n{entry['text']}\n"
            srt_subtitles.append(srt_entry)
        
        # Prepare output
        output = "\n".join(srt_subtitles)
        
        # Save to file
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(output)
        print(f"Subtitles saved to {output_file}")
        return True
            
    except Exception as e:
        print(f"Error downloading subtitles for video '{video_title}' ({video_url}): {str(e)}")
        return False

def download_subtitles_for_playlist(playlist_url, output_dir=None):
    """Download subtitles for all videos in a YouTube playlist."""
    try:
        # Create playlist object
        playlist = Playlist(playlist_url)
        
        # Create output directory if specified
        if output_dir:
            os.makedirs(output_dir, exist_ok=True)
        
        # Get all video URLs
        video_urls = playlist.video_urls
        
        print(f"Found {len(video_urls)} videos in playlist")
        
        # Download subtitles for each video
        successful_downloads = 0
        failed_videos = []
        for i, video_url in enumerate(video_urls, 1):
            print(f"\nProcessing video {i}/{len(video_urls)}")
            if output_dir:
                # Let the function generate filename from video title
                success = download_subtitles_for_video(video_url)
            else:
                success = download_subtitles_for_video(video_url)
            
            if success:
                successful_downloads += 1
            else:
                video_id = extract_video_id(video_url)
                title, _ = get_video_info(video_id)
                failed_videos.append(title)
        
        print(f"\nDownloaded subtitles for {successful_downloads} out of {len(video_urls)} videos")
        if failed_videos:
            print("\nFailed to download subtitles for these videos:")
            for title in failed_videos:
                print(f"- {title}")
        
    except Exception as e:
        print(f"Error processing playlist: {str(e)}")

def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print("  For single video: python subtitle_downloader.py <youtube_url> [output_file]")
        print("  For playlist: python subtitle_downloader.py --playlist <playlist_url> [output_directory]")
        return
    
    if sys.argv[1] == "--playlist":
        if len(sys.argv) < 3:
            print("Error: Playlist URL is required")
            return
        playlist_url = sys.argv[2]
        output_dir = sys.argv[3] if len(sys.argv) > 3 else None
        download_subtitles_for_playlist(playlist_url, output_dir)
    else:
        video_url = sys.argv[1]
        output_file = sys.argv[2] if len(sys.argv) > 2 else None
        download_subtitles_for_video(video_url, output_file)

if __name__ == "__main__":
    main() 