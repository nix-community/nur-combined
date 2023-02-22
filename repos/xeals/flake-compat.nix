{ src, system ? builtins.currentSystem or "unknown-system" }:

let
  lockFilePath = "${src}/flake.lock";
  lockFile = builtins.fromJSON (builtins.readFile lockFilePath);
  nixpkgs = lockFile.nodes.nixpkgs.locked;
  tarball = fetchTarball {
    url = "https://github.com/${nixpkgs.owner}/${nixpkgs.repo}/archive/${nixpkgs.rev}.zip";
    sha256 = nixpkgs.narHash;
  };
in
import tarball { inherit system; }
