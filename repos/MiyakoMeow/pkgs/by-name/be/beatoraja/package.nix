{
  stdenv,
  lib,
  pkgs,

  fetchurl,
  fetchzip,
  callPackage,
  makeDesktopItem,
  copyDesktopItems,
  unzip,
  ...
}:

let
  commonAttrs = import ./lib/common.nix {
    inherit
      stdenv
      lib
      pkgs
      fetchurl
      fetchzip
      callPackage
      makeDesktopItem
      copyDesktopItems
      unzip
      ;
  };
in
commonAttrs {
  # 默认参数，使用 sources 中的配置
}
