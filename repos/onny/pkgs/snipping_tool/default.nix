{ pkgs ? import <nixpkgs> {}, ... }:

let
  pname = "snipping_tool";
  version = "1.0.0";
  stdenv = pkgs.stdenv;
in
  stdenv.mkDerivation {

    inherit pname version;

    src = ./.;

    installPhase =
      let
        script = pkgs.writeShellScriptBin "snipping_tool" ''
	  if [ "$1" = "-v" ]; then
	    wf-recorder -g "$(slurp)" -f "$(xdg-user-dir PICTURES)/$(date +'%Y-%m-%d-%H%M%S_wf-recorder.mp4')"
	  else
	    slurp | grim -g - - | wl-copy && wl-paste > "$(xdg-user-dir PICTURES)/$(date +'%Y-%m-%d-%H%M%S_grim.png')"
	  fi
        '';
      in
      ''
        mkdir $out;
        cp -r ${script}/* $out/
      '';

  }

