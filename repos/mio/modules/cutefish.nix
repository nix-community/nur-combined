# Cutefish Wayland desktop. The session shows up as "Cutefish (Wayland)" in an
# existing display manager, or log in through cutefish-dm by enabling
# services.displayManager.cutefish-dm.
#
# Package installation follows Plasma and GNOME: the shell is required, the
# default applications can be dropped with environment.cutefish.excludePackages,
# and there is no single joined package.
{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.desktopManager.cutefish;
  dmCfg = config.services.displayManager.cutefish-dm;
  # Components come from the NUR overlay. Importing only this module still
  # builds them from the same expressions.
  cu =
    if pkgs ? cutefish-core && pkgs ? cutefish-compositor && pkgs ? xdg-desktop-portal-cutefish then
      pkgs
    else
      pkgs.callPackage ../pkgs/desktops/cutefish/scope.nix { };

  # Shell, session services, settings, and artwork.
  corePackages = [
    cu.cutefish-core
    cu.cutefish-compositor
    cu.cutefish-filemanager # paints the desktop icons
    cu.cutefish-settings
    cu.cutefish-qt-plugins
    cu.cutefish-icons
    cu.cutefish-wallpapers
  ];

  # Installed by default. Drop entries with environment.cutefish.excludePackages.
  optionalPackages = [
    cu.cutefish-terminal
    cu.cutefish-text-editor
    cu.cutefish-video-player
    cu.cutefish-calendar
    cu.cutefish-system-monitor
    cu.cutefish-calculator
  ];
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "desktopManager" "cutefish" "package" ] ''
      The Cutefish module installs the shell and the default applications itself.
      Drop an application with environment.cutefish.excludePackages.
    '')
  ];

  options = {
    services.desktopManager.cutefish = {
      enable = lib.mkEnableOption "Cutefish Wayland desktop (https://cutefish.org/)";
    };

    services.displayManager.cutefish-dm = {
      enable = lib.mkEnableOption "the Cutefish display manager (https://cutefish.org/)";
    };

    environment.cutefish.excludePackages = lib.mkOption {
      description = "List of default Cutefish applications to exclude from the environment.";
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.cutefish-video-player ]";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      warnings = lib.optional (!config.services.displayManager.enable) ''
        services.desktopManager.cutefish.enable registers the Cutefish Wayland session.
        Enable a display manager such as services.displayManager.sddm.enable or
        services.displayManager.cutefish-dm.enable to log in to it.
      '';

      services.displayManager.sessionPackages = [ cu.cutefish-core ];
      services.displayManager.defaultSession = lib.mkDefault "cutefish-wayland";

      environment.systemPackages =
        corePackages
        ++ utils.removePackagesByName optionalPackages config.environment.cutefish.excludePackages
        ++ [
          pkgs.adwaita-icon-theme
          pkgs.hwdata
          pkgs.shared-mime-info
          pkgs.xkeyboard-config
          pkgs.xdg-user-dirs
          pkgs.xdg-utils
        ];

      # xdg.icons links /share/icons, and /lib already covers Qt plugins.
      # Wallpapers and session files are looked up under /run/current-system/sw.
      environment.pathsToLink = [
        "/share/backgrounds"
        "/share/cutefish"
        "/share/wayland-sessions"
        "/share/X11/xkb"
      ];

      services.graphical-desktop.enable = true;
      qt.enable = lib.mkDefault true;
      hardware.graphics.enable = lib.mkDefault true;
      programs.xwayland.enable = lib.mkDefault true;
      xdg.icons.enable = true;

      services.udev.packages = [ cu.cutefish-core ];
      services.dbus.packages = [ cu.cutefish-core ];
      # Privacy, locales and the session. The portal unit comes in with extraPortals.
      systemd.packages = [ cu.cutefish-core ];

      # The session starts this after exporting its environment. Units that are
      # PartOf graphical-session.target (xdg-desktop-portal needs it as a
      # Requisite) then become startable.
      systemd.user.targets.graphical-session = {
        description = "Cutefish graphical session";
        documentation = [ "man:systemd.special(7)" ];
      };

      # graphical-session.target is dependency-only, so the session starts this
      # oneshot, which pulls the target in.
      systemd.user.services.cutefish-graphical-session = {
        description = "Activate the Cutefish graphical session target";
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.coreutils}/bin/true";
          RemainAfterExit = true;
        };
      };

      security.polkit.enable = true;
      # The lock screen calls pam_start("cutefish-auth") and must not open a login session.
      security.pam.services.cutefish-auth = {
        startSession = false;
        setEnvironment = false;
      };

      services.accounts-daemon.enable = lib.mkDefault true;
      services.udisks2.enable = lib.mkDefault true;
      services.upower.enable = lib.mkDefault true;
      services.power-profiles-daemon.enable = lib.mkDefault true;
      services.gnome.gnome-keyring.enable = lib.mkDefault true;
      hardware.bluetooth.enable = lib.mkDefault true;
      networking.networkmanager.enable = lib.mkDefault true;

      services.pipewire = {
        enable = lib.mkDefault true;
        alsa.enable = lib.mkDefault true;
        pulse.enable = lib.mkDefault true;
        wireplumber.enable = lib.mkDefault true;
      };

      # cutefish-core ships lib/modules-load.d/cutefish-ddc.conf, which NixOS does not load.
      boot.kernelModules = [ "i2c-dev" ];

      fonts.packages = [
        pkgs.noto-fonts
        pkgs.noto-fonts-color-emoji
        pkgs.dejavu_fonts
      ];

      xdg.portal = {
        enable = true;
        extraPortals = [
          cu.xdg-desktop-portal-cutefish
          pkgs.xdg-desktop-portal-gtk
        ];
        # share/xdg-desktop-portal/cutefish-portals.conf. The portal lowercases
        # XDG_CURRENT_DESKTOP=Cutefish before looking that file up.
        configPackages = lib.mkDefault [ cu.xdg-desktop-portal-cutefish ];
      };
    })

    (lib.mkIf dmCfg.enable {
      warnings = lib.optional (!cfg.enable) ''
        services.displayManager.cutefish-dm.enable starts the Cutefish display manager,
        but services.desktopManager.cutefish.enable is what registers the Cutefish
        session it logs in to.
      '';

      services.displayManager.enable = true;
      hardware.graphics.enable = lib.mkDefault true;

      # The daemon reads /etc/cutefish-dm.conf. Automatic login uses the shared
      # display manager options, as SDDM and LightDM do.
      environment.etc."cutefish-dm.conf".text =
        lib.optionalString
          (
            config.services.displayManager.autoLogin.enable
            && config.services.displayManager.autoLogin.user != null
          )
          ''
            [Autologin]
            User=${config.services.displayManager.autoLogin.user}
            ${lib.optionalString (
              config.services.displayManager.sessionData.autologinSession != null
            ) "Session=${config.services.displayManager.sessionData.autologinSession}"}
          '';

      # The login screen runs as its own system user. The session's compositor
      # reaches the GPU and input devices through logind, not these groups.
      users.groups.cutefish-greeter = { };
      users.users.cutefish-greeter = {
        isSystemUser = true;
        group = "cutefish-greeter";
        home = "/var/lib/cutefish-greeter";
        createHome = true;
        shell = "${pkgs.bash}/bin/bash";
      };

      systemd.packages = [ cu.cutefish-dm ];
      systemd.services.cutefish-dm = {
        aliases = [ "display-manager.service" ];
        wantedBy = [ "graphical.target" ];
      };
      services.dbus.packages = [ cu.cutefish-dm ];

      # The daemon authenticates users through pam_start("cutefish-dm") and
      # starts the login screen through pam_start("cutefish-dm-greeter"), the
      # same split as LightDM.
      security.pam.services.cutefish-dm = {
        useDefaultRules = false;
        rules = {
          auth = utils.pam.autoOrderRules [
            {
              name = "login";
              control = "substack";
              modulePath = "login";
            }
          ];
          account = utils.pam.autoOrderRules [
            {
              name = "login";
              control = "include";
              modulePath = "login";
            }
          ];
          password = utils.pam.autoOrderRules [
            {
              name = "login";
              control = "substack";
              modulePath = "login";
            }
          ];
          session = utils.pam.autoOrderRules [
            {
              name = "login";
              control = "include";
              modulePath = "login";
            }
          ];
        };
      };

      security.pam.services.cutefish-dm-greeter = {
        useDefaultRules = false;
        rules = {
          auth = utils.pam.autoOrderRules [
            {
              name = "greeter-user";
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
              settings.audit = true;
              settings.quiet_success = true;
              args = lib.mkAfter [
                "user"
                "="
                "cutefish-greeter"
              ];
            }
            {
              name = "permit";
              control = "optional";
              modulePath = "${config.security.pam.package}/lib/security/pam_permit.so";
            }
          ];
          account = utils.pam.autoOrderRules [
            {
              name = "greeter-user";
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
              settings.audit = true;
              settings.quiet_success = true;
              args = lib.mkAfter [
                "user"
                "="
                "cutefish-greeter"
              ];
            }
            {
              name = "unix";
              control = "sufficient";
              modulePath = config.security.pam.pam_unixModulePath;
            }
          ];
          password = utils.pam.autoOrderRules [
            {
              name = "deny";
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_deny.so";
            }
          ];
          session = utils.pam.autoOrderRules [
            {
              name = "greeter-user";
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
              settings.audit = true;
              settings.quiet_success = true;
              args = lib.mkAfter [
                "user"
                "="
                "cutefish-greeter"
              ];
            }
            {
              name = "env";
              control = "required";
              modulePath = "${config.security.pam.package}/lib/security/pam_env.so";
              settings.conffile = "/etc/pam/environment";
              settings.readenv = 0;
            }
            {
              name = "systemd";
              control = "optional";
              modulePath = "${config.systemd.package}/lib/security/pam_systemd.so";
            }
            {
              name = "keyinit";
              control = "optional";
              modulePath = "${config.security.pam.package}/lib/security/pam_keyinit.so";
              settings.force = true;
              settings.revoke = true;
            }
            {
              name = "permit";
              control = "optional";
              modulePath = "${config.security.pam.package}/lib/security/pam_permit.so";
            }
          ];
        };
      };
    })
  ];
}
