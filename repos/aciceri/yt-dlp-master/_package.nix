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
    version = "2026.07.04-unstable-2026-08-04";
    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "5d6b8c8cd19785c3086ae3a9ec618c45e25eb3bc";
      hash = "sha256-tDJNBlmgOCX2FRNgojk9wvC5z9MQFVu7xo/e20ghjp8=";
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
