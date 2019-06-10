{ pkgs }:
let mkGhc = v: pkgs.callPackage ./artifact.nix {} { bindistTarball = (mkTarball v); ncursesVersion = "5";};
    hashes = builtins.fromJSON (builtins.readFile ./hashes.json);
    mkTarball = { url, hash, ...}: pkgs.fetchurl { url = url;
                                                       sha256 = hash;
                                                     };
in
  builtins.mapAttrs (_: v: mkGhc v ) hashes // { inherit mkGhc; }
