{
  minio,
  lib,
  fetchFromGitHub,
  nix-update-script,
}:
minio.overrideAttrs (
  final: prev: rec {
    pname = "minio-latest";
    version = "2025-10-15T17-29-55Z";
    src = fetchFromGitHub {
      owner = "minio";
      repo = "minio";
      rev = "RELEASE.${version}";
      sha256 = "sha256-HbjmCJYkWyRRHKriLP6QohaXYLk3QEVfi32Krq3ujjo=";
    };
    vendorHash = "sha256-BFnTJE9QFWmPsx90hDTG8MusdnwaBPYJxM5bCFk3hew=";
    passthru = prev.passthru // {
      updateScriptEnabled = true;
      updateScript = nix-update-script { attrPath = final.pname; } ++ [
        "--version-regex"
        "RELEASE\\.(.*)"
      ];
    };
    meta = prev.meta // {
      broken = !(lib.versionAtLeast minio.go.version "1.24");
      maintainers = with lib.maintainers; [ yinfeng ];
    };
  }
)
