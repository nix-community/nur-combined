{ sources ? import ../../nix/sources.nix, pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  defaultAttrs = {
    builder = ./builder.sh;
    baseInputs = [ ];
    src = fetchFromGitHub {
      owner = "pigpigyyy";
      repo = "MoonPlus";
      rev = "fc79fc1a549db29d3eada79cc2084eecd5b7fe21";
      sha256 = "0jscq6jwjpj3qhcfdvdssvili7037fc8c3bmbk0b58dh1vj56kp3";
    };
    version = "HEAD";
    name = "MoonPlus";
    system = builtins.currentSystem;

    installPhase = ''
      ls
      install -D bin/release/moonp $out/bin/moonp
    '';
  };

in stdenv.mkDerivation defaultAttrs
