{
  projectDir,
  nixpkgsVersion ? "nixpkgs-unstable",
}: let
  pkgs = import <nixpkgs> {overlays = [(import ../../overlay.nix)];};
  configuration = with pkgs.lib;
    pipe (builtins.readDir projectDir) [
      (filterAttrs (n: v: (hasPrefix "nix-config-" n) && v == "regular"))
      attrNames
      (sort (a: b: a < b))
      (map (n: parseFile "${projectDir}/${n}"))
      (foldl' recursiveUpdate {})
    ];

  parseFile = path:
    if pkgs.lib.hasSuffix ".json" path
    then builtins.fromJSON (builtins.readFile path)
    else if pkgs.lib.hasSuffix ".nix" path
    then import path
    else throw "Unsupported file type";

  overrides = import "${projectDir}/overrides.nix";
in
  pkgs.mkSbtDerivation.withOverrides overrides ({
      pname = "test-project";
      version = "unstable";
      src = projectDir;

      depsArchivalStrategy = "copy";
      depsSha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

      buildPhase = ''
        sbt run
      '';

      installPhase = ''
        touch $out
      '';
    }
    // configuration)
