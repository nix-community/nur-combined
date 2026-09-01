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
    version = "2026.08.19-unstable-2026-08-30";
    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "bbc809a1161d3bfca51fa36f59dda35556ee85a0";
      hash = "sha256-Wlr4N21a/oQQbxQ8n5P0aJHq9EegTTqeKzHoGC9U5zo=";
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
