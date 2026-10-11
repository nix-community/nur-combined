{ config, lib, pkgs, ... }:

let
  cfg = config.quriosity.sddm-themes.echo;

  userConfig = {
    General = {
      type = cfg.type;
      login_mode = cfg.loginMode;
      distro = cfg.distroName;
      font = cfg.font.family;
      font_size = cfg.fontSize;
      boot_interval = cfg.bootInterval;
      use_24h = cfg.use24h;
      background_opacity = cfg.backgroundOpacity;
      blur_radius = cfg.blurRadius;
    }
    // lib.optionalAttrs (cfg.background != null) {
      background = "${cfg.background}";
    };
  };

  themeConfUser = (pkgs.formats.ini { }).generate "echo-theme.conf.user" userConfig;

  baseTheme = cfg.package;

  configuredTheme = pkgs.runCommand "echo-sddm-configured" { } ''
    mkdir -p $out/share/sddm/themes
    cp -r ${baseTheme}/share/sddm/themes/echo $out/share/sddm/themes/echo
    chmod -R u+w $out/share/sddm/themes/echo
    cp ${themeConfUser} $out/share/sddm/themes/echo/theme.conf.user
  '';
in
{
  options.quriosity.sddm-themes.echo = {
    enable = lib.mkEnableOption "Echo SDDM theme";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/sddm-themes/echo-sddm { };
      description = "Echo SDDM theme package to use as a base.";
    };

    type = lib.mkOption {
      type = lib.types.enum [ "pure" "frosted" ];
      default = "pure";
      description = ''
        Background style: `pure` (solid black) or `frosted`
        (wallpaper with a blur/opacity effect).
      '';
    };

    loginMode = lib.mkOption {
      type = lib.types.enum [ "select" "tty" ];
      default = "select";
      description = ''
        `select` uses arrow keys to pick a user and session.
        `tty` emulates a terminal login where the username is typed.
      '';
    };

    distroName = lib.mkOption {
      type = lib.types.str;
      default = "${config.system.nixos.distroName} ${config.system.nixos.release} (${config.system.nixos.codeName})";
      defaultText = lib.literalExpression ''
        "''${config.system.nixos.distroName} ''${config.system.nixos.release} (''${config.system.nixos.codeName})"
      '';
      example = "NixOS 25.05 (Warbler)";
      description = ''
        Operating system name shown in the theme. Defaults to the NixOS
        `/etc/os-release` `PRETTY_NAME`. The theme cannot read it at runtime
        (the SDDM greeter blocks file access), so it is injected here.
      '';
    };

    background = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/path/to/wallpaper.png";
      description = ''
        Wallpaper for `type = "frosted"`, referenced by its absolute store
        path. When null the bundled `assets/backgrounds/background.png`
        is used.
      '';
    };

    font = {
      family = lib.mkOption {
        type = lib.types.str;
        default = "JetBrains Mono";
        description = "Monospace font family used by the theme.";
      };
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = pkgs.jetbrains-mono;
        example = lib.literalExpression "pkgs.cascadia-code";
        description = ''
          Package providing `font.family`. Set to null if the font is
          installed some other way.
        '';
      };
    };

    fontSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 14;
      description = "Font size in pixels.";
    };

    bootInterval = lib.mkOption {
      type = lib.types.ints.positive;
      default = 72;
      description = "Boot animation speed in milliseconds per log line.";
    };

    use24h = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use a 24-hour clock instead of 12-hour with AM/PM.";
    };

    backgroundOpacity = lib.mkOption {
      type = lib.types.float;
      default = 0.35;
      description = "Terminal window background opacity for `frosted` (0.0–1.0).";
    };

    blurRadius = lib.mkOption {
      type = lib.types.ints.between 0 100;
      default = 54;
      description = "Blur strength for `frosted` mode (0–100).";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.backgroundOpacity >= 0.0 && cfg.backgroundOpacity <= 1.0;
        message = "quriosity.sddm-themes.echo: backgroundOpacity must be between 0.0 and 1.0.";
      }
    ];

    environment.systemPackages = [ configuredTheme ];

    services.displayManager.sddm.extraPackages = [ pkgs.qt6.qt5compat ];

    services.displayManager.sddm.theme = lib.mkDefault "echo";

    fonts.packages = lib.optional (cfg.font.package != null) cfg.font.package;
  };
}