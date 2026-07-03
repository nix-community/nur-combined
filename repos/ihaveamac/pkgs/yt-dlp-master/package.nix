{
  fetchFromGitHub,
  yt-dlp,
}:

yt-dlp.overrideAttrs (final: prev: {
  version = "2026.06.09-unstable-2026-07-02";

  src = fetchFromGitHub {
    owner = "yt-dlp";
    repo = "yt-dlp";
    rev = "ad9a6f25f69344ebc060f7be223e5c19fc03e9b5";
    hash = "sha256-l7NqY4Asn/iPx3HCxN5z495WGZuHpBEx0lU55hWCkRI=";
  };

  meta = prev.meta // {
    description = prev.meta.description + " (master branch)";
  };
})
