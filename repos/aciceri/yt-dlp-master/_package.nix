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
    version = "2025.12.08-unstable-2025-12-19";
    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "c0c9cac55446f7bf48370ba60c06f9cf5bc48d15";
      hash = "sha256-mqVgruC+O49HQK4DndmK/fC7IHm+AXsv9+yrLW5Jf5U=";
    };
    passthru = previousAttrs.passthru // {
      updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake yt-dlp-master --version=branch";
    };
    meta = previousAttrs.meta // {
      maintainers = previousAttrs.meta.maintainers ++ [ lib.maintainers.aciceri ];
    };
  }
)
