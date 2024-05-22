{ fetchurl }:

{ timestamp, url, ... }@args:

(fetchurl (
  {
    url = "https://web.archive.org/web/${timestamp}/${url}";
  }
  // removeAttrs args [
    "timestamp"
    "url"
  ]
))
