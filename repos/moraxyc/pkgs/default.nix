{
  pkgs ? import <nixpkgs> { },
  pkgs-stable ? pkgs,
  sources ? pkgs.callPackage ../_sources/generated.nix { },
  inputs' ? null,
  system ? builtins.currentSystem,
  ...
}:

let
  call = p: pkgs.lib.callPackageWith (pkgs // { inherit sources; }) p { };
  call-stable = p: pkgs-stable.lib.callPackageWith (pkgs-stable // { inherit sources; }) p { };
in
{
  exloli-next = call ./exloli-next;
  v2ray-rules-dat = call ./v2ray-rules-dat;
  libinput-three-finger-drag = call ./libinput-three-finger-drag;
  adguard-cli = call ./adguard-cli;
  english-words = call ./english-words;
}
