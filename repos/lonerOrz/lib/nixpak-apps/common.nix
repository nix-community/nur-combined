{
  config,
  lib,
  pkgs,
  sloth,
  ...
}:

let
  inherit (lib) mkDefault;

  cfg = config.nixpakCommon;

  fontTools = import ./fonts.nix { inherit pkgs; };

  fontConfig = fontTools.mk {
    name = "nixpak-common-fonts";
    inherit (cfg.fonts)
      package
      family
      extraPackages
      aliases
      minimal
      ;
  };

  gtkSchemaDir = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}";

  portalCallBase = [
    "org.freedesktop.DBus.Introspectable.*"
    "org.freedesktop.portal.OpenURI.*"
    "org.freedesktop.portal.Settings.*"
    "org.freedesktop.portal.Notification.*"
    "org.freedesktop.portal.Screenshot.*"
    "org.freedesktop.portal.ScreenCast.*"
    "org.freedesktop.portal.Request.*"
  ];

  runtimePackages = with pkgs; [
    xdg-utils
    coreutils
    bashInteractive
    gnused
    gnugrep
    findutils
    procps
    glibc.bin
  ];

in
{
  options.nixpakCommon = {
    fileChooser.enable = lib.mkEnableOption "FileChooser portal access";

    fonts = {
      enable = lib.mkEnableOption "custom font configuration" // {
        default = true;
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = fontTools.defaultPrimaryFont;
        description = "Primary font package.";
      };

      family = lib.mkOption {
        type = lib.types.str;
        default = fontTools.defaultPrimaryFamily;
        description = "Primary font family name used for fontconfig and aliasing.";
      };

      file = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        description = ''
          Primary font TTF file for sandboxes that replace bundled fonts.
          Set to null when `package` changes; set explicitly to keep replacement.
        '';
      };

      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Additional font packages to include.";
      };

      aliases = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Font family names redirected to the primary font.";
      };

      minimal = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Use a minimal Fontconfig configuration without system conf.d.";
      };
    };
  };

  config = {
    nixpakCommon.fonts.file = lib.mkOptionDefault (
      if cfg.fonts.package == fontTools.defaultPrimaryFont then fontTools.defaultPrimaryFile else null
    );

    # Switch these two font options together; otherwise /etc/fonts is bound twice.
    fonts.enable = lib.mkDefault false;

    etc.sslCertificates.enable = mkDefault true;

    gpu = {
      enable = mkDefault true;
      provider = mkDefault "nixos";
    };

    dbus = {
      enable = mkDefault true;

      policies = lib.mapAttrs (_: value: mkDefault value) {
        "org.freedesktop.Notifications" = "talk";
        "ca.desrt.dconf" = "talk";
        "org.kde.StatusNotifierWatcher" = "talk";
        "org.freedesktop.portal.Fcitx" = "talk";
        "org.freedesktop.portal.Fcitx.*" = "talk";
        "org.freedesktop.portal.IBus" = "talk";
        "org.freedesktop.portal.IBus.*" = "talk";
      };

      rules = {
        call."org.freedesktop.portal.Desktop" =
          portalCallBase
          ++ lib.optionals cfg.fileChooser.enable [
            "org.freedesktop.portal.FileChooser.*"
            "org.freedesktop.DBus.Properties.Get"
          ];

        broadcast."org.freedesktop.portal.Desktop" = [
          "org.freedesktop.portal.Request.*"
          "org.freedesktop.portal.Settings.*"
          "org.freedesktop.portal.Notification.*"
          "org.freedesktop.portal.OpenURI.*"
          "org.freedesktop.portal.Screenshot.*"
          "org.freedesktop.portal.ScreenCast.*"
        ];
      };
    };

    bubblewrap = {
      network = mkDefault true;

      env = {
        GTK_IM_MODULE = mkDefault "fcitx";
        QT_IM_MODULE = mkDefault "fcitx";
        XMODIFIERS = mkDefault "@im=fcitx";

        LD_LIBRARY_PATH = mkDefault (
          sloth.concat [
            "/run/opengl-driver/lib:/run/opengl-driver-32/lib:"
            (sloth.envOr "LD_LIBRARY_PATH" "")
          ]
        );

        GIO_EXTRA_MODULES = mkDefault (
          sloth.concat [
            "${pkgs.dconf.lib}/lib/gio/modules:"
            (sloth.envOr "GIO_EXTRA_MODULES" "")
          ]
        );

        XDG_DATA_DIRS = mkDefault (
          sloth.concat [
            "${gtkSchemaDir}:"
            (sloth.envOr "XDG_DATA_DIRS" "/run/current-system/sw/share:/usr/local/share:/usr/share")
          ]
        );

        QT_QPA_PLATFORM = mkDefault "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = mkDefault "wayland";
        NIXOS_OZONE_WL = mkDefault "1";
        NIXOS_XDG_OPEN_USE_PORTAL = mkDefault "1";

        PATH = mkDefault (
          sloth.concat [
            (lib.makeBinPath runtimePackages + ":")
            (sloth.envOr "PATH" "")
          ]
        );
      };

      extraStorePaths =
        runtimePackages
        ++ [
          pkgs.gtk3
          pkgs.dconf.lib
        ]
        ++ lib.optionals cfg.fonts.enable [
          fontConfig
        ];

      bind.dev = [
        "/dev/snd"
        "/dev/shm"
      ];

      bind.rw = lib.mkBefore [
        (sloth.concat' sloth.runtimeDir "/at-spi/bus")
        (sloth.concat' sloth.runtimeDir "/gvfsd")
        (sloth.concat' sloth.runtimeDir "/dconf")

        [
          (sloth.mkdir sloth.appConfigDir)
          sloth.xdgConfigHome
        ]
        [
          (sloth.mkdir sloth.appDataDir)
          sloth.xdgDataHome
        ]
        [
          (sloth.mkdir sloth.appCacheDir)
          sloth.xdgCacheHome
        ]
        [
          (sloth.mkdir (sloth.concat' sloth.appDir "/state"))
          sloth.xdgStateHome
        ]
      ];

      tmpfs = [ "/tmp" ];

      bind.ro = lib.mkAfter (
        [
          [
            "${pkgs.bashInteractive}/bin/bash"
            "/bin/sh"
          ]
          [
            "${pkgs.bashInteractive}/bin/bash"
            "/bin/bash"
          ]

          "/etc/os-release"
          "/etc/lsb-release"
          "/etc/localtime"
          "/etc/egl"
          "/etc/static/egl"
          "/etc/static/alsa"
          "/etc/alsa"

          "/run/opengl-driver-32"

          "/run/current-system/sw/share/glib-2.0/schemas"
          "/run/current-system/sw/share/mime"
          "/run/current-system/sw/share/icons"
          "/run/current-system/sw/share/applications"

          (sloth.concat' sloth.runtimeDir "/doc")

          "/etc/passwd"
          "/etc/group"
          "/etc/machine-id"
        ]

        ++ lib.optionals cfg.fonts.enable [
          [
            "${fontConfig}/etc/fonts"
            "/etc/fonts"
          ]
        ]
      );

      sockets = {
        wayland = mkDefault true;
        pipewire = mkDefault true;
        pulse = mkDefault true;
        x11 = mkDefault false;
      };
    };
  };
}
