#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p "python3.withPackages (ps: [ ps.feedsearch-crawler ])"

from feedsearch_crawler import search, sort_urls
from feedsearch_crawler.crawler import coerce_url

import json
import logging
import sys
url, jsonPath = sys.argv[1:]

logging.getLogger().setLevel(logging.DEBUG)
logging.getLogger().addHandler(logging.StreamHandler(sys.stdout))
logging.getLogger(__name__).debug("logging enabled")

def try_scheme(url: str, scheme: str):
    url = coerce_url(url, default_scheme=scheme)
    print(f"trying {url}")
    items = search(url, total_timeout=180, request_timeout=90, max_content_length=100*1024*1024)
    return sort_urls(items)

items = try_scheme(url, "https") or try_scheme(url, "http")

# print all results
serialized = [item.serialize() for item in items]
for item in serialized:
        print(json.dumps(item, sort_keys=True, indent=2))

# save the first result to disk
keep = serialized[0] if serialized else {}
results = json.dumps(keep, sort_keys=True, indent=2)
with open(jsonPath, "w") as out:
        out.write(results)
