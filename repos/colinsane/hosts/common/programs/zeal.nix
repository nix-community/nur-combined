{ config, lib, pkgs, ... }:
let
  inherit (builtins) map;
  inherit (lib) mkIf mkOption optionalString types;
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
  sane.programs.zeal = {
    # packageUnwrapped = pkgs.zeal-qt6;  #< TODO: upgrade system to qt6 versions of everything (i.e. jellyfin-media-player, nheko)
    packageUnwrapped = pkgs.zeal-qt5;
    slowToBuild = true;
    persist.byStore.plaintext = [
      ".cache/Zeal"
      ".local/share/Zeal"
    ];
    fs.".local/share/Zeal/Zeal/docsets/system".symlink.target = "/run/current-system/sw/share/docset";
    suggestedPrograms = [ "docsets" ];
  };

  sane.programs.docsets = {
    configOption = mkOption {
      type = configOpts;
      default = {};
    };
    packageUnwrapped = pkgs.symlinkJoin {
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

    sandbox.enable = false;  # meta-package; no binaries
  };

  environment.pathsToLink = mkIf config.sane.programs.zeal.enabled [
    "/share/docset"
  ];
}
