{
  writeTextFile,
  callPackage,
  lib,
  _meta,
  newScope,
  packages,
  ...
}: let
  nurPackages =
    builtins.removeAttrs
    (lib.makeScope newScope packages)
    [
      "newScope"
      "callPackage"
      "overrideScope"
      "overrideScope'"
      "packages"
    ];

  inherit
    (callPackage ../../../helpers/flatten-pkgs.nix {})
    isIndependentDerivation
    isHiddenName
    shouldRecurseForDerivations
    flattenPkgs'
    isPlatform
    ;

  packageSets =
    lib.filterAttrs
    (n: v:
      (builtins.tryEval v).success
      && !(isHiddenName n)
      && (shouldRecurseForDerivations v))
    nurPackages;

  packageList = prefix: ps: (lib.mapAttrsToList (n: v:
    (lib.optionals (isPlatform "x86_64-linux" v) [
      "packages.x86_64-linux.${n}"
    ])
    ++ (lib.optionals (isPlatform "aarch64-linux" v) [
      "packages.aarch64-linux.${n}"
    ])) (flattenPkgs' prefix "." ps));

  uncategorizedOutput =
    packageList
    ""
    (lib.filterAttrs
      (n: v: (builtins.tryEval v).success && isIndependentDerivation v)
      nurPackages);

  packageSetsOutput = lib.mapAttrsToList (n: v: packageList n v) packageSets;
in
  writeTextFile rec {
    name = "garnix.yaml";
    text = builtins.toJSON {
      builds.include = lib.naturalSort (lib.flatten (uncategorizedOutput ++ packageSetsOutput));
    };
    derivationArgs.passthru.text = text;
    meta = {
      description = "garnix.yaml for Lan Tian's NUR Repo";
      homepage = "https://github.com/xddxdd/nur-packages";
      license = lib.licenses.unlicense;
    };
  }
