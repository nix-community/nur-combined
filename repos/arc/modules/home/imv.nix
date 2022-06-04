{ lib, config, pkgs, ... }: with lib; let
  cfg = config.programs.imv;
  colourType = types.str;
  ini = pkgs.formats.ini { };
  options = {
    # man 5 imv
    background = mkOption {
      type = with types; nullOr (either (enum [ "checks" ]) colourType);
      defaultText = "000000";
      default = null;
    };
    fullscreen = mkOption {
      type = with types; nullOr bool;
      defaultText = "false";
      default = null;
    };
    width = mkOption {
      type = with types; nullOr int;
      defaultText = "1280";
      default = null;
    };
    height = mkOption {
      type = with types; nullOr int;
      defaultText = "720";
      default = null;
    };
    list_files_at_exit = mkOption {
      type = with types; nullOr bool;
      defaultText = "false";
      default = null;
    };
    loop_input = mkOption {
      type = with types; nullOr bool;
      defaultText = "true";
      default = null;
    };
    recursively = mkOption {
      type = with types; nullOr bool;
      defaultText = "false";
      default = null;
    };
    scaling_mode = mkOption {
      type = with types; nullOr (enum [ "none" "shrink" "full" "crop" ]);
      defaultText = "full";
      default = null;
    };
    slideshow_duration = mkOption {
      type = with types; nullOr int;
      defaultText = "0";
      default = null;
    };
    suppress_default_binds = mkOption {
      type = with types; nullOr types.bool;
      defaultText = "false";
      default = null;
    };
    title_text = mkOption {
      type = with types; nullOr str;
      default = null;
    };
    upscaling_method = mkOption {
      type = with types; nullOr (enum [ "linear" "nearest_neighbour" ]);
      defaultText = "linear";
      default = null;
    };
  };
in {
  options.programs.imv = {
    enable = mkEnableOption "imv image viewer";
    package = mkOption {
      type = types.package;
      default = pkgs.imv;
      defaultText = "pkgs.imv";
    };
    aliases = mkOption {
      type = with types; attrsOf str;
      default = { };
    };
    binds = mkOption {
      type = with types; attrsOf str;
      default = { };
    };
    config = mkOption {
      type = types.submodule {
        freeformType = with types; attrsOf (nullOr (oneOf [ bool int colourType str ]));

        inherit options;
      };
    };
    configContent = mkOption {
      type = ini.type;
    };
    initialPan = {
      x = mkOption {
        type = types.int;
        defaultText = "50%";
        default = 50;
      };
      y = mkOption {
        type = types.int;
        defaultText = "50%";
        default = 50;
      };
    };
    overlay = {
      enable = mkOption {
        type = with types; nullOr bool;
        defaultText = "false";
        default = null;
      };
      font = mkOption {
        type = with types; nullOr str;
        defaultText = "Monospace:24";
        default = null;
      };
      text = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      color = mkOption {
        type = types.nullOr colourType;
        defaultText = "ffffff";
        default = null;
      };
      alpha = mkOption {
        type = with types; nullOr ints.u8;
        defaultText = "0xff";
        default = null;
      };
      backgroundColor = mkOption {
        type = types.nullOr colourType;
        defaultText = "000000";
        default = null;
      };
      backgroundAlpha = mkOption {
        type = with types; nullOr ints.u8;
        defaultText = "0xc3";
        default = null;
      };
      position = mkOption {
        type = with types; nullOr (enum [ "bottom" "top" ]);
        defaultText = "top";
        default = null;
      };
    };
  };

  config = {
    home.packages = mkIf cfg.enable [ cfg.package ];
    xdg.configFile."imv/config" = mkIf cfg.enable {
      source = pkgs.runCommand "imv.ini" {
        configContent = ini.generate "imv" cfg.configContent;
        binds = ini.generate "imv-binds" {
          inherit (cfg) binds;
        };
      } ''
        cat $configContent $binds > $out
      '';
    };
    programs.imv = {
      config = {
        initial_pan = mkIf (cfg.initialPan.x != 50 || cfg.initialPan.y != 50) (mkOptionDefault "${cfg.config.initialPan.x} ${cfg.config.initialPan.y}");
        overlay = mkOptionDefault cfg.overlay.enable;
        overlay_font = mkOptionDefault cfg.overlay.font;
        overlay_text = mkOptionDefault cfg.overlay.text;
        overlay_text_color = mkOptionDefault cfg.overlay.color;
        overlay_text_alpha = mkOptionDefault (mapNullable toHexString cfg.overlay.alpha);
        overlay_background_color = mkOptionDefault cfg.overlay.backgroundColor;
        overlay_background_alpha = mkOptionDefault (mapNullable toHexString cfg.overlay.backgroundAlpha);
        overlay_position_bottom = mkIf (cfg.overlay.position != null) (mkOptionDefault (cfg.overlay.position == "bottom"));
      };
      configContent = {
        options = mapAttrs (_: v: mkIf (v != null) (mkOptionDefault v)) cfg.config;
        aliases = cfg.aliases;
      };
    };
  };
}
