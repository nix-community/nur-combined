{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
}:

let
  rev = "dfb0ba79b5f41ca6fed25a03d2a5cd6996ec4753";
  sha256 = "0cr8mlcxyib4rd8xj65hb1wxwlmppgg4823z7h3dbbxi273gz5b0";

in (pkgs.emacs.override { srcRepo = true; }).overrideAttrs(old: rec {
  name = "emacs-${version}";
  version = builtins.substring 0 7 rev;

  src = pkgs.fetchFromGitHub {
    owner = "emacs-mirror";
    repo = "emacs";
    inherit sha256 rev;
  };

  patches = [
    ./clean-env.patch
    (lib.elemAt old.patches 1)
  ];

})
