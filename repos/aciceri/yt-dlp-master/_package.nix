{
  yt-dlp,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
yt-dlp.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "yt-dlp-master";
    version = "2025.09.26-unstable-2025-10-01";
    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "5513036104ed9710f624c537fb3644b07a0680db";
      hash = "sha256-U0jrjzFTEqrnfgS6PPUAHqd61exbjmqIu2MkomKiPAE=";
    };
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script {
        extraArgs = [ "--version=branch" ];
      };
    };
    meta = previousAttrs.meta // {
      maintainers = previousAttrs.meta.maintainers ++ [ lib.maintainers.aciceri ];
    };
  }
)
