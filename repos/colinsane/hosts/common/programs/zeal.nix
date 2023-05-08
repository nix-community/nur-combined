{ config, lib, pkgs, sane-lib, ... }:
let
  inherit (builtins) map;
  inherit (lib) mkIf mkOption optionalString types;
  inherit (sane-lib) mapToAttrs;
  cfg = config.sane.programs.docsets.config;
  configOpts = types.submodule {
    options = {
      rustPkgs = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };
in {
  sane.programs.zeal-qt5 = {
    persist.plaintext = [
      ".cache/Zeal"
      ".local/share/Zeal"
    ];
    fs.".local/share/Zeal/Zeal/docsets/system" = sane-lib.fs.wantedSymlinkTo "/run/current-system/sw/share/docset";
    suggestedPrograms = [ "docsets" ];
  };

  sane.programs.docsets = {
    configOption = mkOption {
      type = configOpts;
      default = {};
    };
    package = pkgs.symlinkJoin {
      name = "docsets";
      # build each package with rust docs
      paths = map (name:
        let
          orig = pkgs."${name}";
          withDocs = orig.overrideAttrs (upstream: {
            nativeBuildInputs = upstream.nativeBuildInputs or [] ++ [
              pkgs.cargoDocsetHook
            ];
          });
        in
        "${toString withDocs}/share/docset"
      ) cfg.rustPkgs;
      # link only the docs (not any binaries)
      postBuild = optionalString (cfg.rustPkgs != []) ''
        mkdir -p $out/share/docset
        mv $out/*.docset $out/share/docset
      '';
    };
  };

  environment.pathsToLink = mkIf config.sane.programs.zeal-qt5.enabled [
    "/share/docset"
  ];
}
