# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{
  pkgs ? import <nixpkgs> { },
}:
let
  # 特殊属性（需保留）
  specialAttrs = {
    # The `lib`, `modules`, and `overlays` names are special
    lib = import ./lib { inherit pkgs; }; # functions
    modules = import ./modules; # NixOS modules
    overlays = import ./overlays; # nixpkgs overlays
  };

  # 导入单个包或包集合（返回原始结果）
  importPackage =
    path:
    pkgs.callPackage path {
    };

  # 安全导入：失败时仅告警并返回 null，不中断其它包解析
  safeImportPackage =
    path:
    let
      attempt = builtins.tryEval (importPackage path);
    in
    if attempt.success then
      attempt.value
    else
      builtins.trace "WARNING: Failed to import package at ${toString path}; skipping." null;

  # 基础库
  lib = pkgs.lib;

  # === 统一的包发现逻辑 ===
  # 判断目录是否包含直接包文件
  hasDirectPackage =
    dirPath:
    let
      pkg = dirPath + "/package.nix";
      def = dirPath + "/default.nix";
    in
    (builtins.pathExists pkg) || (builtins.pathExists def);

  # 获取目录下的直接包文件路径（可选仅允许 package.nix）
  getDirectPackageFile =
    dirPath: onlyPkg:
    let
      pkg = dirPath + "/package.nix";
      def = dirPath + "/default.nix";
    in
    if builtins.pathExists pkg then
      pkg
    else if (!onlyPkg) && builtins.pathExists def then
      def
    else
      null;

  # 递归发现：
  # - depth = 0 仅检查直接包
  # - depth > 0 若无直接包则在子目录中继续查找
  discover =
    dirPath: depth: flatten: onlyPkg:
    let
      directFile = getDirectPackageFile dirPath onlyPkg;

      # 将任意值拍平成 { name -> derivation } 形式（忽略 meta、非 derivation）
      flattenValue =
        value:
        if value == null then
          { }
        else if lib.isDerivation value then
          let
            key = value.pname or (lib.getName value);
          in
          {
            ${key} = value;
          }
        else if lib.isAttrs value then
          let
            names = lib.attrNames value;
          in
          lib.foldl' (
            acc: n:
            let
              v = value.${n};
            in
            if n == "meta" then
              acc
            else if lib.isDerivation v then
              let
                k = v.pname or (lib.getName v);
              in
              if acc ? ${k} then
                builtins.trace "WARNING: Duplicate package name '${k}' detected. Replacing old derivation." (
                  acc // { ${k} = v; }
                )
              else
                acc // { ${k} = v; }
            else if lib.isAttrs v then
              acc // (flattenValue v)
            else
              acc
          ) { } names
        else
          { };
    in
    if directFile != null then
      let
        v = safeImportPackage directFile;
      in
      if flatten then flattenValue v else v
    else if depth > 0 then
      let
        contents = builtins.readDir dirPath;
        subDirs = lib.filterAttrs (name: type: type == "directory") contents;
        subNames = builtins.attrNames subDirs;
        results = map (
          n:
          let
            subPath = dirPath + "/${n}";
            r = discover subPath (depth - 1) flatten onlyPkg;
          in
          {
            name = n;
            value = r;
          }
        ) subNames;
      in
      if flatten then
        lib.foldl' (
          acc: a:
          if a.value == null then
            acc
          else
            let
              names = lib.attrNames a.value;
            in
            lib.foldl' (
              acc2: n:
              if acc2 ? ${n} then
                builtins.trace "WARNING: Duplicate package name '${n}' detected. Replacing old derivation." (
                  acc2 // { ${n} = a.value.${n}; }
                )
              else
                acc2 // { ${n} = a.value.${n}; }
            ) acc names
        ) { } results
      else
        builtins.listToAttrs (lib.filter (a: a.value != null) results)
    else if flatten then
      { }
    else
      null;

  # 发现 by-name 下的包树（两层：字母/组 -> 包）并扁平化为顶层属性
  allOutsidePackages = discover ./pkgs/by-name 2 true true;

  # 发现其它分组（排除 by-name），保留分组层级
  nestedPackages =
    let
      pkgsDir = ./pkgs;
    in
    if builtins.pathExists pkgsDir then
      let
        contents = builtins.readDir pkgsDir;
        groupDirs = lib.filterAttrs (name: type: type == "directory" && name != "by-name") contents;
        groupNames = builtins.attrNames groupDirs;
        groups = map (
          groupName:
          let
            groupPath = pkgsDir + "/${groupName}";
            result = discover groupPath 1 false false;
          in
          if result != null then { ${groupName} = result; } else { }
        ) groupNames;
      in
      lib.foldl' (acc: s: acc // s) { } groups
    else
      { };
in
specialAttrs // allOutsidePackages // nestedPackages
# 按组名组织的包组（每个组是平面属性集）
