#!/bin/bash
# Uso: ./rss_podcast_info.sh <RSS_URL> <N>
# Exemplo: ./rss_podcast_info.sh https://anchor.fm/s/10f2ba74/podcast/rss 3

set -euo pipefail

RSS_URL="$1"
N="$2"

if [ -z "$RSS_URL" ] || [ -z "$N" ]; then
  echo "Uso: $0 <RSS_URL> <N>"
  exit 1
fi

# Dependência check
if ! command -v xmlstarlet >/dev/null 2>&1; then
  echo "Este script requer xmlstarlet. Instale com: sudo apt install xmlstarlet"
  exit 2
fi

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

if ! curl -sSfL "$RSS_URL" -o "$TMP"; then
  echo "Falha ao baixar $RSS_URL"
  exit 3
fi

PODCAST_NAME=$(xmlstarlet sel -t \
  -v "normalize-space((/rss/channel/title | /feed/title | //title)[1])" \
  "$TMP" 2>/dev/null)
PODCAST_NAME=${PODCAST_NAME:-}

xmlstarlet sel -t \
  -m "((//item)|(//entry))[position() <= $N]" \
    -v "normalize-space(title)" -o ";" \
    -v "normalize-space(((link[@href]/@href) | (link[@rel='alternate']/@href) | (link[not(@href)]/@href) | (enclosure/@url) | (guid) | (link))[1])" -o ";" \
    -v "normalize-space(((pubDate) | (updated) | (published))[1])" -n \
  "$TMP" 2>/dev/null | while IFS=";" read -r TITLE LINK RAWDATE; do
    # Converte data para dd/mm/yyyy
    if DATE_FMT=$(date -d "$RAWDATE" +"%d/%m/%Y" 2>/dev/null); then
      PUBDATE="$DATE_FMT"
    else
      PUBDATE="$RAWDATE" # fallback se não der pra converter
    fi
    echo "${PODCAST_NAME};${TITLE};${LINK};${PUBDATE}"
  done

