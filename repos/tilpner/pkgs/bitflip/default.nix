# Idea by symphorien
# Nix only scans outputs for paths to buildInputs, so a two-stage process
# where the intermediate artifact hides all store paths from Nix
# will remove references to all store paths.

# This is meant to be used on generated filesystem images, and will
# add two (!!!) copies of that filesystem to your store. Even with
# an optimised store, this still doubles the disk usage. The advantage
# of the reduced runtime closure becomes apparent when using nix-copy-closure
# on a slow connection.

# TODO: compile bitflip with musl to remove glibc from allowedReferences

{ stdenv, binutils, rustc, nukeReferences, glibc }:

let
  bitflip = stdenv.mkDerivation {
    name = "bitflip";
    src = ./bitflip.rs;
    
    nativeBuildInputs = [ rustc nukeReferences ];

    unpackPhase = ":";

    buildPhase = ''
      rustc -O $src -o ./bitflip
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp ./bitflip $out/bin/
      # strip -s $out/bin/bitflip
    '';
  };

  # this may not be compatible with darwin, according to clever
  flip = file: derivation {
    name = "flipped";
    input = file;
    allowedReferences = [ glibc ];
    preferLocalBuild = true;
    builder = "${bitflip}/bin/bitflip";
    inherit (stdenv) system;
  };

  flipTwice = file: flip (flip file);
in { inherit bitflip flip flipTwice; }
