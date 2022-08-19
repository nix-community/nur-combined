{ pkgs, lib ? pkgs.lib, ... }:

with builtins;
with lib; rec {
  gltf-pipeline = let
    mypkgs = import (pkgs.fetchFromGitHub {
      owner = "nagy";
      repo = "nixpkgs";
      rev = "946704823d74346749656fb80c208716cf600c02";
      hash = "sha256-AY1AFFOirNQS6VM6DXit50mPpzwH6zefNJOIB41JKCA=";
    }) { };
  in mypkgs.nodePackages.gltf-pipeline;

  mkGlb2Gltf = src:
    let
      thename =
        replaceStrings [ ".glb" ] [ ".gltf" ] (toString (baseNameOf src));
    in pkgs.runCommand thename {
      nativeBuildInputs = [ gltf-pipeline ];
      inherit src;
    } ''
      gltf-pipeline --input $src --output $out
    '';
}
