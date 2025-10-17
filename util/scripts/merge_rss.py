#!/usr/bin/env python3
# coding: utf-8

import feedparser
from datetime import datetime
import sys

MAX_ITEMS = 50
CHANNEL_LINK = "https://fronteirases.github.io/redeemilias/"
OUTPUT_FILE = "rede-emilias.xml"

if len(sys.argv) < 2 or len(sys.argv) > 6:
    print("Uso: python3 merge_rss_final.py rss1 [rss2 rss3 rss4 rss5]")
    sys.exit(1)

FEEDS = sys.argv[1:]
all_items = []

for url in FEEDS:
    print(f"Processando feed: {url}")
    d = feedparser.parse(url)
    podcast_title = d.feed.get("title", "Desconhecido")
    for entry in d.entries:
        title = entry.get("title", "Sem título")
        link = entry.get("link", "")
        description = entry.get("summary", "")
        pubdate_str = entry.get("published", entry.get("updated", ""))
        if pubdate_str and hasattr(entry, "published_parsed"):
            pubdate = datetime(*entry.published_parsed[:6])
        else:
            pubdate = datetime.now()

        # Pega enclosure se existir
        enclosure = None
        if "enclosures" in entry and len(entry.enclosures) > 0:
            enc = entry.enclosures[0]
            # Garante que temos url, type e length se disponíveis
            url_enc = enc.get("href") or ""
            type_enc = enc.get("type") or "audio/mpeg"
            length_enc = enc.get("length") or "0"
            enclosure = (url_enc, type_enc, length_enc)

        all_items.append({
            "pubdate": pubdate,
            "podcast_title": podcast_title,
            "title": title,
            "link": link,
            "description": description,
            "enclosure": enclosure
        })

# Ordena por data descendente
all_items.sort(key=lambda x: x["pubdate"], reverse=True)

# Gera RSS
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
        f.write('  <item>\n')
        f.write(f'    <title><![CDATA[{item["title"]}]]></title>\n')
        f.write(f'    <link>{item["link"]}</link>\n')
        f.write(f'    <pubDate>{item["pubdate"].strftime("%a, %d %b %Y %H:%M:%S %z")}</pubDate>\n')
        f.write(f'    <description><![CDATA[Publicado originalmente em {item["podcast_title"]}]]></description>\n')
        # Adiciona enclosure se disponível
        if item["enclosure"]:
            url_enc, type_enc, length_enc = item["enclosure"]
            f.write(f'    <enclosure url="{url_enc}" type="{type_enc}" length="{length_enc}"/>\n')
        f.write('  </item>\n')

    f.write('</channel>\n')
    f.write('</rss>\n')

print(f"✅ Feed combinado criado em: {OUTPUT_FILE}")

