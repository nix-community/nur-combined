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
    version = "2025.10.22-unstable-2025-10-28";
    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "6d05cee4df30774ddce5c5c751fd2118f40c24fe";
      hash = "sha256-PMz8yQOaiW9jTw3agAUpemMBYAQdDafQ7FxZK4jkJ6s=";
    };
    passthru = previousAttrs.passthru // {
      updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake yt-dlp-master --version=branch";
    };
    meta = previousAttrs.meta // {
      maintainers = previousAttrs.meta.maintainers ++ [ lib.maintainers.aciceri ];
    };
  }
)
