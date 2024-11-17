#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p feedsearch-crawler -p python3

from feedsearch_crawler import search, sort_urls
from feedsearch_crawler.crawler import coerce_url

import argparse
import json
import logging
import sys

logger = logging.getLogger(__name__)

def try_scheme(url: str, scheme: str):
    url = coerce_url(url, default_scheme=scheme)
    print(f"trying {url}")
    items = search(url, total_timeout=180, request_timeout=90, max_content_length=100*1024*1024)
    return sort_urls(items)

def clean_item(item: dict) -> dict:
    ''' remove keys/values i don't care to keep in git '''
    item = {
        k:v for k,v in item.items() if k in [
            # "content_type",
            "description",  # not used
            # "favicon",
            # "favicon_data_uri",  # embedded favicon
            # "hubs",  # PubSub hubs
            "is_podcast",   # used by <hosts/common/feeds.nix>
            # "is_push",
            # "last_updated",
            # "self_url",
            "site_name",    # not used
            "site_url",     # not used
            "title",        # used by <hosts/common/feeds.nix> (and others)
            "url",          # used by <hosts/common/feeds.nix> (and many others)
            "velocity",     # used by <hosts/common/feeds.nix>
            # "version",
        ] and item[k] is not None
    }
    # clean up characters for better printability
    for k in "title", "site_name", "description":
        if k not in item: continue
        item[k] = item[k] \
            .replace("\u2013", "-") \
            .replace("\u2019", "'") \

    return item

def try_load_existing_feed(path_: str) -> dict:
    try:
        f = open(path_, "r")
    except:
        return {}
    else:
        return json.loads(f.read())

def select_feed(feeds: list[dict], prefer_podcast: bool) -> dict:
    feeds = sorted(feeds, key=lambda f: (
        (not f.get("is_podcast", not prefer_podcast) == prefer_podcast),  #< prefer the resuested media format
        -f.get("velocity", 0),  #< prefer higher-velocity sources
        f["url"],  #< prefer shorter URLs
        len(f["title"]) if f.get("title", "") != "" else 1000,  #< prefer shorter titles
        f,
    ))
    return feeds[0] if len(feeds) else {}

def main():
    logging.basicConfig()
    logging.getLogger().setLevel(logging.DEBUG)
    logger.debug("logging enabled")

    parser = argparse.ArgumentParser(usage=__doc__)
    parser.add_argument("url", help="where to start searching for a feed")
    parser.add_argument("output", help="where to save extracted feed data (should end in .json)")
    parser.add_argument('--podcast', help="if multiple feeds are found, prefer the podcast feed over any text/image feed", action='store_true')

    args = parser.parse_args()

    url, json_path = args.url, args.output

    existing_data = try_load_existing_feed(json_path)

    prefer_podcast = args.podcast or existing_data.get("is_podcast", False)

    items = try_scheme(url, "https") \
        or try_scheme(url, "http") \
        or try_scheme(f"www.{url}", "https") \
        or try_scheme(f"www.{url}", "http") \

    # print all results
    serialized = [item.serialize() for item in items]
    serialized = [clean_item(s) for s in serialized]
    for item in serialized:
        print(json.dumps(item, sort_keys=True, indent=2))

    # save the best feed to disk
    keep = select_feed(serialized, prefer_podcast=prefer_podcast)
    results = json.dumps(keep, sort_keys=True, indent=2)
    with open(json_path, "w") as out:
        out.write(results)

if __name__ == '__main__':
    main()
