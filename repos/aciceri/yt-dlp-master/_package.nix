{
  yt-dlp,
  fetchFromGitHub,
  lib,
  nix-update,
  writeShellScript,
}:
yt-dlp.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "yt-dlp-master";
    version = "2026.03.17-unstable-2026-05-03";
    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "35684c1171dd8b99da825cf43a0b2c06b43824b7";
      hash = "sha256-r3wqC1uYjVa90EqzIdihdKUjA92hMjtNL9kVH7zG70o=";
    };
    postPatch = "";
    passthru = previousAttrs.passthru // {
      updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake yt-dlp-master --version=branch";
    };
    meta = previousAttrs.meta // {
      maintainers = previousAttrs.meta.maintainers ++ [ lib.maintainers.aciceri ];
    };
  }
)
