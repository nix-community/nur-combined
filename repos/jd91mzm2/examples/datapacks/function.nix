{ pkgs ? import <nixpkgs> {} }:

let
  nur = pkgs.callPackage ./../.. {};
  inherit (nur) minecraft;
in

minecraft.mkDatapack {
  meta = {
    name = "minimal";
    description = "A test datapack";
  };
  additions = {
    functions.init = ''
      say Hello World
    '';
  };
  modifications = {
    tags.functions.load = {
      replace = true;
      values = ["minimal:init"];
    };
  };
}
