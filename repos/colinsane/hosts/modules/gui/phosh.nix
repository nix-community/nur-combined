{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.sane.gui.phosh;
in
{
  options = {
    sane.gui.phosh.enable = mkOption {
      default = false;
      type = types.bool;
    };
    sane.gui.phosh.useGreeter = mkOption {
      description = ''
        launch phosh via a greeter (like lightdm-mobile-greeter).
        phosh is usable without a greeter, but skipping the greeter means no PAM session.
      '';
      default = true;
      type = types.bool;
    };
  };

  config = mkMerge [
    {
      sane.programs.phoshApps = {
        package = null;
        suggestedPrograms = [
          "guiApps"
          # TODO: see about removing gnome-bluetooth if the in-built gnome-settings bluetooth manager can work
          "gnome.gnome-bluetooth"
          "gnome.gnome-terminal"
          "phosh-mobile-settings"
          # "plasma5Packages.konsole"  # more reliable terminal
        ];
      };
    }
    {
      sane.programs = {
        inherit (pkgs // {
          "gnome.gnome-bluetooth" = pkgs.gnome.gnome-bluetooth;
          "gnome.gnome-terminal" = pkgs.gnome.gnome-terminal;
          "plasma5Packages.konsole" = pkgs.plasma5Packages.konsole;
        })
          phosh-mobile-settings
          "plasma5Packages.konsole"
          # "gnome.gnome-bluetooth"
          "gnome.gnome-terminal"
        ;
      };
    }

    (mkIf cfg.enable {
      sane.programs.phoshApps.enableFor.user.colin = true;

      # TODO(2023/02/28): remove this qt.style = "gtk2" override.
      # gnome by default tells qt to stylize its apps similar to gnome.
      # but the package needed for that doesn't cross-compile, hence i disable that here.
      # qt.platformTheme = "gtk2";
      # qt.style = "gtk2";

      # docs: https://github.com/NixOS/nixpkgs/blob/nixos-22.05/nixos/modules/services/x11/desktop-managers/phosh.nix
      services.xserver.desktopManager.phosh = {
        enable = true;
        user = "colin";
        group = "users";
        phocConfig = {
          # xwayland = "true";
          # find default outputs by catting /etc/phosh/phoc.ini
          outputs.DSI-1 = {
            scale = 1.5;
          };
        };
      };

      # phosh enables `services.gnome.{core-os-services, core-shell}`
      # and this in turn enables some default apps we don't really care about.
      # see <nixos/modules/services/x11/desktop-managers/gnome.nix>
      environment.gnome.excludePackages = with pkgs; [
        # gnome.gnome-menus  # unused outside gnome classic, but probably harmless
        gnome-tour
      ];
      services.dleyna-renderer.enable = false;
      services.dleyna-server.enable = false;
      services.gnome.gnome-browser-connector.enable = false;
      services.gnome.gnome-initial-setup.enable = false;
      services.gnome.gnome-online-accounts.enable = false;
      services.gnome.gnome-remote-desktop.enable = false;
      services.gnome.gnome-user-share.enable = false;
      services.gnome.rygel.enable = false;

      # gnome doesn't use mkDefault for these -- unclear why not
      services.gnome.evolution-data-server.enable = mkForce false;
      services.gnome.gnome-online-miners.enable = mkForce false;

      # XXX: phosh enables networkmanager by default; can probably disable these lines
      networking.useDHCP = false;
      networking.networkmanager.enable = true;
      networking.wireless.enable = lib.mkForce false;

      # XXX: not clear if these are actually needed?
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;

      hardware.opengl.enable = true;
      hardware.opengl.driSupport = true;

      environment.variables = {
        # Qt apps won't always start unless this env var is set
        QT_QPA_PLATFORM = "wayland";
        # electron apps (e.g. Element) should use the wayland backend
        # toggle this to have electron apps (e.g. Element) use the wayland backend.
        # phocConfig.xwayland should be disabled if you do this
        NIXOS_OZONE_WL = "1";
      };

      programs.dconf.packages = [
        # org.kde.konsole.desktop
        (pkgs.writeTextFile {
          name = "dconf-phosh-settings";
          destination = "/etc/dconf/db/site.d/00_phosh_settings";
          text = ''
            [org/gnome/desktop/interface]
            show-battery-percentage=true

            [org/gnome/settings-daemon/plugins/power]
            sleep-inactive-ac-timeout=5400
            sleep-inactive-battery-timeout=5400

            [sm/puri/phosh]
            favorites=['gpodder.desktop', 'nheko.desktop', 'sublime-music.desktop', 'firefox.desktop', 'org.gnome.Terminal.desktop']
          '';
        })
      ];
    })

    (mkIf (cfg.enable && cfg.useGreeter) {
      services.xserver.enable = true;
      # NB: setting defaultSession has the critical side-effect that it lets org.freedesktop.AccountsService
      # know that our user exists. this ensures lightdm succeeds when calling /org/freedesktop/AccountsServices ListCachedUsers
      # lightdm greeters get the login users from lightdm which gets it from org.freedesktop.Accounts.ListCachedUsers.
      # this requires the user we want to login as to be cached.
      services.xserver.displayManager.job.preStart = ''
        ${pkgs.systemd}/bin/busctl call org.freedesktop.Accounts /org/freedesktop/Accounts org.freedesktop.Accounts CacheUser s colin
      '';
      # services.xserver.displayManager.defaultSession = "sm.puri.Phosh";  # XXX: not sure why this doesn't propagate correctly.
      services.xserver.displayManager.lightdm.extraSeatDefaults = ''
        user-session = phosh
      '';
      # services.xserver.displayManager.lightdm.greeters.gtk.enable = false;  # gtk greeter overrides our own?
      # services.xserver.displayManager.lightdm.greeter = {
      #   enable = true;
      #   package = pkgs.lightdm-mobile-greeter.xgreeters;
      #   name = "lightdm-mobile-greeter";
      # };
      # # services.xserver.displayManager.lightdm.enable = true;

      services.xserver.displayManager.lightdm.enable = true;
      services.xserver.displayManager.lightdm.greeters.mobile.enable = true;

      systemd.services.phosh.wantedBy = lib.mkForce [];  # disable auto-start
    })
  ];
}
