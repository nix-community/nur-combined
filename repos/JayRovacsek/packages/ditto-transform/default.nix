{ self, nixos-rebuild, stdenv, pkgs, lib }:
with lib;
let
  name = "ditto-transform";
  pname = name;
  version = "0.0.1";
  meta = {
    description =
      "A simple shell wrapper for nixos to run a rebuild against a target system";
    platforms = platforms.unix;
  };

  ditto-transform-wrapped = pkgs.writeShellScriptBin "ditto-transform" ''
    TARGET="$1"
    if [ -z "$TARGET" ]
    then
      echo "$0 - Error \$TARGET not set or NULL, use the first parameter to this script to define the target"
    else
      echo "Transforming into: $TARGET"
      ${nixos-rebuild}/bin/nixos-rebuild switch --flake ${self}#$TARGET
    fi
  '';

  phases = [ "installPhase" "fixupPhase" ];

in stdenv.mkDerivation {
  inherit name pname version meta phases;

  buildInputs = [ ditto-transform-wrapped ];

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${ditto-transform-wrapped}/bin/ditto-transform $out/bin
  '';
}
