{ config, lib, ... }:
let
  cfg = config.my.home.direnv;
in
{
  options.my.home.direnv = with lib; {
    enable = my.mkDisableOption "direnv configuration";

    defaultFlake = mkOption {
      type = with types; nullOr str;
      default = null;
      example = "pkgs";
      description = ''
        Which flake from the registry should be used for
        <command>use pkgs</command> by default.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv = {
        # A better `use_nix`
        enable = true;
      };
    };

    xdg.configFile =
      let
        libDir = ./lib;
        contents = builtins.readDir libDir;
        names = lib.attrNames contents;
        files = lib.filter (name: contents.${name} == "regular") names;
        linkLibFile = name:
          lib.nameValuePair
            "direnv/lib/${name}"
            { source = libDir + "/${name}"; };
      in
      lib.my.genAttrs' files linkLibFile;

    home.sessionVariables = lib.mkIf (cfg.defaultFlake != null) {
      DIRENV_DEFAULT_FLAKE = cfg.defaultFlake;
    };
  };
}
