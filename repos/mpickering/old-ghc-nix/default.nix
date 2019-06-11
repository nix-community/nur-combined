{ pkgs }:
let mkGhc = v@{ncursesVersion ? "5", ...}: pkgs.callPackage ./artifact.nix {} { bindistTarball = (mkTarball v); inherit ncursesVersion;};
    hashes = builtins.fromJSON (builtins.readFile ./hashes.json);
    mkTarball = { url, hash, ...}: pkgs.fetchurl { url = url;
                                                       sha256 = hash;
                                                     };
in
  builtins.mapAttrs (_: v: mkGhc v ) hashes // { inherit mkGhc; }
