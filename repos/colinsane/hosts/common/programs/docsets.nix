# a `docset` is an HTML-based archive containing a library or language reference and search index
# - originated from Apple/Xcode: <https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/Documentation_Sets/010-Overview_of_Documentation_Sets/docset_overview.html#//apple_ref/doc/uid/TP40005266-CH13-SW6>
# - still in use via Dash/Zeal: <https://kapeli.com/dash>
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.docsets;
  configOpts = with lib; types.submodule {
    options = {
      pkgs = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = ''
          packages providing /share/docsets which should be linked into the system
        '';
      };
      rustPkgs = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = ''
          rust (cargo)-based packages for which to build and then ship docsets
        '';
      };
    };
  };
in {
  sane.programs.docsets = {
    configOption = with lib; mkOption {
      type = configOpts;
      default = {};
    };
    packageUnwrapped = pkgs.symlinkJoin {
      name = "docsets";
      # link only the docs (not any binaries):
      paths = builtins.map (pkg: "${toString pkg}/share/docsets") cfg.config.pkgs;
      postBuild = ''
        mkdir -p $out/share/docsets
        ${lib.optionalString (cfg.config.pkgs != []) ''
          mv $out/*.docset $out/share/docsets
        ''}
      '';
    };
    sandbox.enable = false;  # meta-package; no binaries

    # ensure we populate the system /share/docsets, not just the user's
    enableFor.system = lib.mkIf (builtins.any (en: en) (builtins.attrValues cfg.enableFor.user)) true;
  };

  environment.pathsToLink = lib.mkIf cfg.enabled [
    "/share/docsets"
  ];

  # populate a few default docsets
  sane.programs.docsets.config.rustPkgs = with pkgs; [
    # lemmy-server
    # mx-sanebot
  ];
  sane.programs.docsets.config.pkgs = with pkgs; [
    # packages which ship docsets natively:
    docsets.lua-std
    # docsets.gtk
    docsets.nix-builtins
    docsets.nixpkgs-lib
    docsets.python3-std
    docsets.rust-std
  ] ++ lib.map
    # reconfigure all the rustPkgs so they ship docsets:
    (p: p.overrideAttrs (upstream: {
      nativeBuildInputs = upstream.nativeBuildInputs or [] ++ [
        pkgs.docsets.cargoDocsetHook
      ];
    }))
    cfg.config.rustPkgs
  ;
}
