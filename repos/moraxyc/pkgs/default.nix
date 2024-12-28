{
  pkgs ? import <nixpkgs> { },
  sources ? pkgs.callPackage ../_sources/generated.nix { },
  inputs' ? null,
  system ? builtins.currentSystem,
  ...
}:

let
  call = p: pkgs.lib.callPackageWith (pkgs // { inherit sources; }) p { };
in
{
  exloli-next = call ./exloli-next;
  v2ray-rules-dat = call ./v2ray-rules-dat;
  pam-watchid = call ./pam-watchid;
}
