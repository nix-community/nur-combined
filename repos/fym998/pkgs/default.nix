{
  pkgs,
  lib ? pkgs.lib,
  ...
}:
let
  # 读取 pkgs 目录下的所有子目录
  packagesDir = ../pkgs;
  packageNames = builtins.filter (name: name != "default.nix") (
    lib.attrNames (builtins.readDir packagesDir)
  );

  # 为每个子目录创建对应的 callPackage 调用
  mkPackage = name: {
    inherit name;
    value = pkgs.callPackage (packagesDir + "/${name}") { };
  };

  # 生成属性集
  packages = lib.filterAttrs (_: v: lib.isDerivation v) (
    builtins.listToAttrs (map mkPackage packageNames)
  );
in
packages
