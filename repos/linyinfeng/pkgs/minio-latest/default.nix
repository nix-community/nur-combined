{
  minio,
  lib,
  fetchFromGitHub,
  nix-update-script,
}:
minio.overrideAttrs (
  final: prev: rec {
    pname = "minio-latest";
    version = "2025-09-07T16-13-09Z";
    src = fetchFromGitHub {
      owner = "minio";
      repo = "minio";
      rev = "RELEASE.${version}";
      sha256 = "sha256-0IVxxeM+h3josP+wnS3q4Nrmd3fT9V+KlHxlwz3QyIQ=";
    };
    vendorHash = "sha256-JrDLUVGtwYqwwB+Suutewi6snHyIpG3DOnDn5O0C+L0=";
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
