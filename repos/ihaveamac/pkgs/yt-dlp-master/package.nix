{
  fetchFromGitHub,
  yt-dlp,
}:

yt-dlp.overrideAttrs (final: prev: {
  version = "2026.06.09-unstable-2026-06-28";

  src = fetchFromGitHub {
    owner = "yt-dlp";
    repo = "yt-dlp";
    rev = "5678b282e2a17a8181e682a9681461b9c82ff008";
    hash = "sha256-8ZHnodqUmR2t2yuLfq5Mb7k84DEWppa0P+ifIprV93Y=";
  };

  meta = prev.meta // {
    description = prev.meta.description + " (master branch)";
  };
})
