#!/bin/bash
# Uso: ./merge_rss.sh rss1 [rss2 rss3 rss4 rss5]
# Exemplo: ./merge_rss.sh https://anchor.fm/s/10f2ba74/podcast/rss https://feeds.simplecast.com/54nAGcIl

set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 5 ]; then
  echo "Uso: $0 <RSS_URL_1> [RSS_URL_2 ... até 5]"
  exit 1
fi

# Verifica dependências
for cmd in xmlstarlet curl date sort; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Falta o comando '$cmd'. Instale antes (ex: sudo apt install xmlstarlet curl coreutils)"
    exit 2
  fi
done

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

OUTFILE="redeemilias.rss"

echo "Baixando e combinando RSSs..."

ALL_ITEMS_FILE="$TMPDIR/all_items.txt"

for URL in "$@"; do
  TMPFILE="$TMPDIR/feed.xml"
  if curl -sSfL "$URL" -o "$TMPFILE"; then
    echo "Processando $URL..."
    xmlstarlet sel -t \
      -m "(//item | //entry)" \
      -v "normalize-space(title)" -o ";;" \
      -v "normalize-space(((link[@href]/@href) | (link | guid | enclosure/@url)[1]))" -o ";;" \
      -v "normalize-space(((pubDate)|(updated)|(published))[1])" -o ";;" \
      -v "normalize-space((/rss/channel/title | /feed/title | //title)[1])" -n \
      "$TMPFILE" 2>/dev/null >> "$ALL_ITEMS_FILE"
  else
    echo "Aviso: não foi possível baixar $URL"
  fi
done

# Ordena por data (descendente)
sort -t';' -k3r "$ALL_ITEMS_FILE" -o "$ALL_ITEMS_FILE"

# Cabeçalho do novo feed
cat > "$OUTFILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
  <title>Rede Emílias de Podcasts</title>
  <link>https://emiliaspodcasts.example.org</link>
  <description>Feed combinado da Rede Emílias de Podcasts</description>
  <language>pt-BR</language>
  <lastBuildDate>$(date -R)</lastBuildDate>
EOF

# Adiciona cada item
while IFS=';;' read -r TITLE LINK DATE SOURCE; do
  [ -z "$TITLE" ] && continue
  if ! DATE_RSS=$(date -d "$DATE" -R 2>/dev/null); then
    DATE_RSS=$(date -R)
  fi
  cat >> "$OUTFILE" <<EOF
  <item>
    <title>${TITLE//&/&amp;}</title>
    <link>${LINK//&/&amp;}</link>
    <pubDate>${DATE_RSS}</pubDate>
    <description>Publicado originalmente em ${SOURCE}</description>
    <source>${SOURCE}</source>
  </item>
EOF
done < "$ALL_ITEMS_FILE"

# Fecha feed
cat >> "$OUTFILE" <<EOF
</channel>
</rss>
EOF

echo "✅ Feed combinado criado em: $OUTFILE"
