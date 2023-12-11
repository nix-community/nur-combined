{ lib, config, pkgs, ... }: with lib; let
  cfg = config.programs.imv;
  colourType = types.strMatching "[0-9a-fA-F]{6}";
  needsBindsAfter = cfg.config.suppress_default_binds == true;
  mapValues = mapAttrs (_: v: mkIf (v != null) (mkOptionDefault v));
  options = with types; {
    # man 5 imv
    background = mkOption {
      type = nullOr (either (enum [ "checks" ]) colourType);
      defaultText = "000000";
      default = null;
    };
    fullscreen = mkOption {
      type = nullOr bool;
      defaultText = "false";
      default = null;
    };
    width = mkOption {
      type = nullOr int;
      defaultText = "1280";
      default = null;
    };
    height = mkOption {
      type = nullOr int;
      defaultText = "720";
      default = null;
    };
    list_files_at_exit = mkOption {
      type = nullOr bool;
      defaultText = "false";
      default = null;
    };
    loop_input = mkOption {
      type = nullOr bool;
      defaultText = "true";
      default = null;
    };
    recursively = mkOption {
      type = nullOr bool;
      defaultText = "false";
      default = null;
    };
    scaling_mode = mkOption {
      type = nullOr (enum [ "none" "shrink" "full" "crop" ]);
      defaultText = "full";
      default = null;
    };
    slideshow_duration = mkOption {
      type = nullOr int;
      defaultText = "0";
      default = null;
    };
    suppress_default_binds = mkOption {
      type = nullOr bool;
      defaultText = "false";
      default = null;
    };
    title_text = mkOption {
      type = nullOr str;
      default = null;
    };
    upscaling_method = mkOption {
      type = nullOr (enum [ "linear" "nearest_neighbour" ]);
      defaultText = "linear";
      default = null;
    };
  };
in {
  options.programs.imv = with types; {
    aliases = mkOption {
      type = attrsOf str;
      default = { };
    };
    binds = mkOption {
      type = attrsOf (nullOr str);
      default = { };
    };
    config = mkOption {
      type = submodule {
        freeformType = attrsOf (nullOr (oneOf [ bool int colourType str ]));

        inherit options;
      };
    };
    settings = mkOption {
      type = attrsOf (attrsOf (oneOf [ bool int str ]));
    };
    initialPan = {
      x = mkOption {
        type = int;
        defaultText = "50%";
        default = 50;
      };
      y = mkOption {
        type = int;
        defaultText = "50%";
        default = 50;
      };
    };
    overlay = {
      enable = mkOption {
        type = nullOr bool;
        defaultText = "false";
        default = null;
      };
      font = mkOption {
        type = nullOr str;
        defaultText = "Monospace:24";
        default = null;
      };
      text = mkOption {
        type = nullOr str;
        default = null;
      };
      color = mkOption {
        type = nullOr colourType;
        defaultText = "ffffff";
        default = null;
      };
      alpha = mkOption {
        type = nullOr ints.u8;
        defaultText = "0xff";
        default = null;
      };
      backgroundColor = mkOption {
        type = nullOr colourType;
        defaultText = "000000";
        default = null;
      };
      backgroundAlpha = mkOption {
        type = nullOr ints.u8;
        defaultText = "0xc3";
        default = null;
      };
      position = mkOption {
        type = nullOr (enum [ "bottom" "top" ]);
        defaultText = "top";
        default = null;
      };
    };
  };

  config = {
    home.packages = mkIf cfg.enable [ cfg.package ];
    xdg.configFile."imv/config" = let
      hasBinds = cfg.settings.binds or cfg.binds != { };
    in mkIf cfg.enable {
      text = mkMerge [
        (mkIf (hasBinds && needsBindsAfter) (mkAfter (generators.toINI { } {
          binds = filterAttrs (_: v: v != null) cfg.binds;
        })))
      ];
    };
    programs.imv = {
      config = {
        initial_pan = mkIf (cfg.initialPan.x != 50 || cfg.initialPan.y != 50) (mkOptionDefault "${cfg.initialPan.x} ${cfg.initialPan.y}");
        overlay = mkOptionDefault cfg.overlay.enable;
        overlay_font = mkOptionDefault cfg.overlay.font;
        overlay_text = mkOptionDefault cfg.overlay.text;
        overlay_text_color = mkOptionDefault cfg.overlay.color;
        overlay_text_alpha = mkOptionDefault (mapNullable toHexString cfg.overlay.alpha);
        overlay_background_color = mkOptionDefault cfg.overlay.backgroundColor;
        overlay_background_alpha = mkOptionDefault (mapNullable toHexString cfg.overlay.backgroundAlpha);
        overlay_position_bottom = mkIf (cfg.overlay.position != null) (mkOptionDefault (cfg.overlay.position == "bottom"));
      };
      settings = {
        options = mapValues cfg.config;
        aliases = cfg.aliases;
        binds = mkIf (!needsBindsAfter) (mapValues cfg.binds);
      };
    };
  };
}
