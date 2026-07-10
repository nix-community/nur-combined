{
  fetchFromGitHub,
  yt-dlp,
}:

yt-dlp.overrideAttrs (final: prev: {
  version = "2026.07.04-unstable-2026-07-09";

  src = fetchFromGitHub {
    owner = "yt-dlp";
    repo = "yt-dlp";
    rev = "59d9ae606a24a80523da35de9fb75b71eb35b501";
    hash = "sha256-ZGk0ufcQqS4lu8d4vgplt8VNOFrdMDR1bqajI3DEKa4=";
  };

  meta = prev.meta // {
    description = prev.meta.description + " (master branch)";
  };
})
