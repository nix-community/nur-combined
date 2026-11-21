{
  stdenv,
  lib,
  makeBinPackage,
}:

# Upstream marks every release as pre-release, so source-info.json sets
# "prerelease": true to let manager.py track them.
makeBinPackage (
  {
    pname = "easytier";
    description = "Simple, decentralized mesh VPN with WireGuard support";
    license = lib.licenses.lgpl3Only;
    # release zips ship static musl binaries
    libc = "musl";
    binaries = [
      "easytier-core"
      "easytier-cli"
      "easytier-web"
      "easytier-web-embed"
    ];
    nixSystem = stdenv.hostPlatform.system;
  }
  // (let sourceInfo = lib.importJSON ./source-info.json; in {
    inherit (sourceInfo) owner version hashes;
  })
)
