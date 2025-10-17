#!/usr/bin/env python3
# coding: utf-8

import feedparser
from datetime import datetime
import sys

if len(sys.argv) < 2 or len(sys.argv) > 6:
    print("Uso: python3 merge_rss.py rss1 [rss2 rss3 rss4 rss5]")
    sys.exit(1)

FEEDS = sys.argv[1:]
MAX_ITEMS = 50
CHANNEL_LINK = "https://fronteirases.github.io/redeemilias/"
OUTPUT_FILE = "rede-emilias.xml"

all_items = []

for url in FEEDS:
    print(f"Processando feed: {url}")
    d = feedparser.parse(url)
    podcast_title = d.feed.get("title", "Desconhecido")
    for entry in d.entries:
        title = entry.get("title", "Sem título")
        link = entry.get("link", "")
        # Tenta obter pubDate ou published ou updated
        pubdate = entry.get("published", entry.get("updated", ""))
        if pubdate:
            try:
                # Converte para RFC-2822
                parsed_date = datetime(*entry.published_parsed[:6])
            except Exception:
                parsed_date = datetime.now()
        else:
            parsed_date = datetime.now()
        all_items.append((parsed_date, podcast_title, title, link))

# Ordena por data desc
all_items.sort(reverse=True)

# Monta RSS
with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    f.write('<rss version="2.0">\n')
    f.write('<channel>\n')
    f.write('  <title>Rede Emílias de Podcasts</title>\n')
    f.write(f'  <link>{CHANNEL_LINK}</link>\n')
    f.write('  <description>Feed combinado da Rede Emílias de Podcasts</description>\n')
    f.write('  <language>pt-BR</language>\n')
    f.write(f'  <lastBuildDate>{datetime.now().strftime("%a, %d %b %Y %H:%M:%S %z")}</lastBuildDate>\n')

    for item in all_items[:MAX_ITEMS]:
        date, podcast_title, title, link = item
        f.write('  <item>\n')
        f.write(f'    <title><![CDATA[{title}]]></title>\n')
        f.write(f'    <link>{link}</link>\n')
        f.write(f'    <pubDate>{date.strftime("%a, %d %b %Y %H:%M:%S %z")}</pubDate>\n')
        f.write(f'    <description><![CDATA[Publicado originalmente em {podcast_title}]]></description>\n')
        f.write('  </item>\n')

    f.write('</channel>\n')
    f.write('</rss>\n')

print(f"✅ Feed combinado criado em: {OUTPUT_FILE}")

