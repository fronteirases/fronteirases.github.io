#!/bin/bash
# Uso:
#   ./merge_rss.sh [--max-items N] rss_url1 [rss_url2 ... rss_url5]
# Exemplo:
#   ./merge_rss.sh --max-items 50 https://anchor.fm/s/10f2ba74/podcast/rss https://feeds.simplecast.com/54nAGcIl
#
# Saída: rede-emilias.xml (RSS 2.0)

set -euo pipefail

DEFAULT_CHANNEL_LINK="https://fronteirases.github.io/redeemilias/"
OUTFILE="rede-emilias.xml"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Dependências
for cmd in xmlstarlet curl date sort; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Falta o comando '$cmd'. Instale antes (ex: sudo apt install xmlstarlet curl coreutils)"
    exit 2
  fi
done

# Parse args
MAX_ITEMS=0
FEEDS=()
while (( "$#" )); do
  case "$1" in
    --max-items)
      shift
      if [ -z "${1-}" ]; then
        echo "--max-items requer um valor"
        exit 1
      fi
      MAX_ITEMS="$1"
      shift
      ;;
    *)
      FEEDS+=("$1")
      shift
      ;;
  esac
done

if [ "${#FEEDS[@]}" -lt 1 ] || [ "${#FEEDS[@]}" -gt 5 ]; then
  echo "Uso: $0 [--max-items N] rss_url1 [rss_url2 ... rss_url5]"
  exit 1
fi

ALL_FILE="$TMPDIR/all_items.raw"

# Função pra escapar & < > em XML (usado para link)
escape_xml() {
  local s="$1"
  s="${s//&/&amp;}"
  s="${s//</&lt;}"
  s="${s//>/&gt;}"
  printf "%s" "$s"
}

echo "Baixando e processando ${#FEEDS[@]} feeds..."

for URL in "${FEEDS[@]}"; do
  TMP="$TMPDIR/feed.xml"
  if ! curl -sSfL "$URL" -o "$TMP"; then
    echo "Aviso: não foi possível baixar $URL" >&2
    continue
  fi

  # Extrai nó do título do canal/ feed para usar como source
  SOURCE_TITLE=$(xmlstarlet sel -t -v "normalize-space((/rss/channel/title | /feed/title | //title)[1])" "$TMP" 2>/dev/null || true)
  SOURCE_TITLE=${SOURCE_TITLE:-}

  # Para cada item/entry, imprime campos separados por '|||'
  # ordem: TITLE ||| LINK ||| RAWDATE ||| SOURCE_TITLE
  xmlstarlet sel -t \
    -m "(//item | //entry)" \
    -v "normalize-space(title)" -o "|||" \
    -v "normalize-space(((link[@href]/@href) | (link[@rel='alternate']/@href) | (enclosure/@url) | (guid) | (link/text()))[1])" -o "|||" \
    -v "normalize-space(((pubDate)|(published)|(updated))[1])" -o "|||" \
    -v "normalize-space('$SOURCE_TITLE')" -n \
    "$TMP" 2>/dev/null >> "$ALL_FILE"
done

# Se não teve itens
if [ ! -s "$ALL_FILE" ]; then
  echo "Nenhum item encontrado nos feeds fornecidos."
  exit 0
fi

# Transforma em linhas com epoch para ordenar
SORTABLE="$TMPDIR/sortable.txt"
: > "$SORTABLE"
while IFS='|||' read -r TITLE LINK RAWDATE SOURCE; do
  # Remove leading/trailing spaces
  TITLE="${TITLE## }"; TITLE="${TITLE%% }"
  LINK="${LINK## }"; LINK="${LINK%% }"
  RAWDATE="${RAWDATE## }"; RAWDATE="${RAWDATE%% }"
  SOURCE="${SOURCE## }"; SOURCE="${SOURCE%% }"

  # tenta converter RAWDATE para epoch; se falhar, epoch=0 e pubdate será data atual
  if [ -n "$RAWDATE" ]; then
    if EPOCH=$(date -d "$RAWDATE" +%s 2>/dev/null); then
      :
    else
      EPOCH=0
    fi
  else
    EPOCH=0
  fi

  # Sanitize (remover newlines)
  TITLE="${TITLE//$'\n'/ }"
  LINK="${LINK//$'\n'/ }"
  RAWDATE="${RAWDATE//$'\n'/ }"
  SOURCE="${SOURCE//$'\n'/ }"

  printf "%d|||%s|||%s|||%s|||%s\n" "$EPOCH" "$TITLE" "$LINK" "$RAWDATE" "$SOURCE" >> "$SORTABLE"
done < "$ALL_FILE"

# Ordena por epoch desc (mais recentes primeiro)
SORTED="$TMPDIR/sorted.txt"
sort -t '|' -k1,1nr "$SORTABLE" > "$SORTED"

# Aplica limite se solicitado
FINAL="$TMPDIR/final.txt"
if [ "$MAX_ITEMS" -gt 0 ]; then
  head -n "$MAX_ITEMS" "$SORTED" > "$FINAL"
else
  cat "$SORTED" > "$FINAL"
fi

# Monta arquivo RSS 2.0
cat > "$OUTFILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
  <title>Rede Emílias de Podcasts</title>
  <link>${DEFAULT_CHANNEL_LINK}</link>
  <description>Feed combinado da Rede Emílias de Podcasts</description>
  <language>pt-BR</language>
  <lastBuildDate>$(date -R)</lastBuildDate>
EOF

while IFS='|||' read -r EPOCH TITLE LINK RAWDATE SOURCE; do
  # PubDate formatado (RFC-2822). Se RAWDATE parsear, usa ele; se não, tenta converter a partir do epoch; fallback para now.
  if [ -n "$RAWDATE" ]; then
    if PUB_RFC=$(date -d "$RAWDATE" -R 2>/dev/null); then
      :
    else
      if [ "$EPOCH" -gt 0 ]; then
        PUB_RFC=$(date -d "@$EPOCH" -R)
      else
        PUB_RFC=$(date -R)
      fi
    fi
  else
    if [ "$EPOCH" -gt 0 ]; then
      PUB_RFC=$(date -d "@$EPOCH" -R)
    else
      PUB_RFC=$(date -R)
    fi
  fi

  # Escapa link
  ESC_LINK=$(escape_xml "$LINK")

  # Use CDATA para title e description/source para preservar caracteres especiais
  cat >> "$OUTFILE" <<EOF
  <item>
    <title><![CDATA[$TITLE]]></title>
    <link>${ESC_LINK}</link>
    <pubDate>${PUB_RFC}</pubDate>
    <description><![CDATA[Publicado originalmente em ${SOURCE}${RAWDATE:+ — ${RAWDATE}}]]></description>
    <source><![CDATA[${SOURCE}]]></source>
  </item>
EOF

done < "$FINAL"

cat >> "$OUTFILE" <<EOF
</channel>
</rss>
EOF

echo "✅ Feed combinado criado em: $OUTFILE"

