{ lib, haumea }:

let
  inherit (builtins)
    length
    all
    filter
    foldl'
    isAttrs
    isPath
    attrNames
    attrValues
    readDir
    readFile
    ;
  inherit (lib)
    pipe
    const
    mergeAttrs
    mapAttrs
    mapAttrs'
    mapAttrsToList
    zipAttrsWith
    filterAttrs
    recursiveUpdate
    nameValuePair
    last
    hasPrefix
    hasSuffix
    removeSuffix
    ;
  inherit (lib.filesystem) listFilesRecursive;

  list =
    readDir: pred: d:
    pipe d [
      readDir
      (filterAttrs (_: v: pred v))
      attrNames
    ];
in

rec {
  # region builtins/lib-based

  /**
    readDir but the names are absolute paths
  */
  readDir' = d: mapAttrs' (n: v: nameValuePair "${toString d}/${n}" v) (readDir d);

  /**
    Return a list of directories within
  */
  listDirs = list readDir (t: t == "directory");
  /**
    Return a list of paths to directories within
  */
  listDirs' = list readDir' (t: t == "directory");

  /**
    Return a list of files within
  */
  listFiles = list readDir (t: t == "regular");
  /**
    Return a list of paths to files within
  */
  listFiles' = list readDir' (t: t == "regular");

  /**
    Return a list of items within
  */
  listAll = list readDir (const true);
  /**
    Return a list of paths to items within
  */
  listAll' = list readDir' (const true);

  /**
    Recursively read a directory and return an attribute set where
    subdirectories are nested sets and files are their absolute paths
  */
  dirToAttrs =
    d:
    pipe d [
      readDir
      (mapAttrs (
        n: v: if v == "directory" then dirToAttrs "${toString d}/${n}" else "${toString d}/${n}"
      ))
    ];

  /**
    Generate an attribute set to be used in e.g. nixosModules.
    I don't use this anymore since I switched to haumea.
  */
  genModules =
    d:
    let
      contents = readDir d;
    in
    if contents ? "default.nix" then
      { ${baseNameOf d} = d; }
    else
      mapAttrs' (n: v: nameValuePair "${baseNameOf d}-${n}" v) (
        pipe contents [
          (filterAttrs (n: v: hasSuffix ".nix" n && v == "regular"))
          (mapAttrs' (n: _: nameValuePair (removeSuffix ".nix" n) "${toString d}/${n}"))
        ]
        // pipe contents [
          (filterAttrs (_: v: v == "directory"))
          (mapAttrsToList (n: _: genModules "${toString d}/${n}"))
          (zipAttrsWith (const last))
        ]
      );

  /**
    Recursively collect all modules in a directory, excluding those that start
    with `# noauto`. Recursion stops when a default.nix is found.
    I don't use this anymore since I switched to haumea.
  */
  collectModules =
    d:
    let
      files = pipe d [
        listFilesRecursive
        (map toString) # hasSuffix and removeSuffix get weird when dealing with paths
        (filter (hasSuffix ".nix"))
        (filter (f: !hasPrefix "# noauto" (readFile f)))
      ];
      # Directories with default.nix
      defaultDirs = pipe files [
        (filter (hasSuffix "/default.nix"))
        (map (removeSuffix "/default.nix"))
      ];
    in
    filter (f: all (d: !hasPrefix d f || f == "${d}/default.nix") defaultDirs) files;

  # endregion
  # region haumea-based

  transformers = {
    /**
      If a directory contains default.nix, raise it and ignore all other modules
      in that directory.
    */
    raiseDefault = _: v: v.default or v;

    /**
      Use parent directory path for `default.nix`. This is because nix treats
      these two paths as different modules and doesn't deduplicate if both are
      imported.
    */
    removeDefaultSuffix = _: v: if isPath v && baseNameOf v == "default.nix" then dirOf v else v;

    /**
      For pkgs/by-name
    */
    callPackage =
      pkgs: ks: v:
      if
        length ks == 0 # root
      then
        pipe v [
          attrValues
          (filter isAttrs)
          (foldl' mergeAttrs { })
        ]
      else if length ks == 2 && v ? package then
        pkgs.callPackage v.package { }
      else
        v;

    /**
      Collect the values into a flat list
    */
    toList = _: v: if isAttrs v then lib.flatten (attrValues v) else [ v ];

    /**
      Flatten the attribute set by concatenating the keys. Useful for
      nixosModules and homeModules.
    */
    flatten =
      _: v1:
      if isAttrs v1 then
        pipe v1 [
          (mapAttrsToList (
            k2: v2:
            if isAttrs v2 then mapAttrs' (k3: v3: nameValuePair "${k2}-${k3}" v3) v2 else { ${k2} = v2; }
          ))
          (foldl' recursiveUpdate { })
        ]
      else
        v1;
  };

  /**
    Represent a directory as a tree of paths to nix modules.
  */
  toModuleTree =
    src:
    haumea.lib.load {
      inherit src;
      loader = haumea.lib.loaders.path;
      transformer = transformers.removeDefaultSuffix;
    };

  /**
    Return an attribute set of all modules under a directory, prepending
    subdirectory names to keys. If there is a default.nix in a directory, it is
    *raised* and all other modules in that directory are ignored.
  */
  toModuleAttr =
    src:
    haumea.lib.load {
      inherit src;
      loader = haumea.lib.loaders.path;
      transformer = with transformers; [
        raiseDefault
        removeDefaultSuffix
        flatten
      ];
    };

  /**
    Like `toModuleAttr`, but also prepend the root directory name to keys.
  */
  toModuleAttr' = src: transformers.flatten [ ] { ${baseNameOf src} = toModuleAttr src; };

  /**
    List paths of all modules under a directory. If there is a default.nix in a
    directory, it is *raised* and all other modules in that directory are
    ignored.
  */
  toModuleList =
    src:
    haumea.lib.load {
      inherit src;
      loader = haumea.lib.loaders.path;
      transformer = with transformers; [
        raiseDefault
        removeDefaultSuffix
        toList
      ];
    };

  /**
    Return an attrset of packages under a directory with the pkgs/by-name
    structure.
  */
  toPackages =
    pkgs: src:
    haumea.lib.load {
      inherit src;
      loader = haumea.lib.loaders.path;
      transformer = transformers.callPackage pkgs;
    };

  # endregion
}
