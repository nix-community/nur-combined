{
  pkgs ? import <nixpkgs> { },
  pkgs-stable ? pkgs,
  pkgs-cuda ? pkgs,
  sources ? pkgs.callPackage ../_sources/generated.nix { },
  inputs' ? null,
  system ? builtins.currentSystem,
  ...
}:

let
  call = p: pkgs.lib.callPackageWith (pkgs // { inherit sources; }) p { };
  call-cuda = p: pkgs.lib.callPackageWith (pkgs-cuda // { inherit sources; }) p { };
  call-stable = p: pkgs.lib.callPackageWith (pkgs-stable // { inherit sources; }) p { };
in
{
  exloli-next = call ./exloli-next;
  v2ray-rules-dat = call ./v2ray-rules-dat;
  adguard-cli = call ./adguard-cli;
  english-words = call ./english-words;
  fcitx5-themes-candlelight = call ./fcitx5-themes-candlelight;

  howdy = call-cuda ./howdy;
  linux-enable-ir-emitter = call-cuda ./linux-enable-ir-emitter;
}
