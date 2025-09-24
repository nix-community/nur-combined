# Desktop essentials
{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.profiles.desktop;
in

{
  imports = [ ./base.nix ];

  options.abszero.profiles.desktop.enable = mkExternalEnableOption config "desktop profile";

  config = mkIf cfg.enable {
    abszero = {
      profiles.base.enable = true;
      boot.lanzaboote.enable = true;
      services.pipewire.enable = true;
    };

    boot.kernelPackages = pkgs.linuxPackages_cachyos;

    console.useXkbConfig = true; # use xkbOptions in tty.

    fonts.fontconfig = {
      hinting.style = "medium";
      subpixel.rgba = "rgb";
    };

    networking = {
      nameservers = [
        "1.1.1.1" # Cloudflare
        "1.0.0.1" # Cloudflare
        "9.9.9.9" # Quad9
        "149.112.112.112" # Quad9
      ];
      search = [ "~." ]; # Always use global name servers (shouldn't affect VPNs)
      dhcpcd.enable = false;
      networkmanager = {
        enable = true;
        wifi = {
          backend = "iwd";
          macAddress = "random";
        };
      };
      wireless.iwd = {
        enable = true;
        settings = {
          General = {
            # EnableNetworkConfiguration = true;
            AddressRandomization = "once"; # Randomize a single time when iwd starts
            DisableANQP = false; # Use Hotspot 2.0
          };
          Network.NameResolvingService = "systemd"; # Use resolved
          Settings.AlwaysRandomizeAddress = true;
        };
      };
    };

    security.rtkit.enable = true;

    services = {
      automatic-timezoned.enable = true;
      libinput = {
        enable = true;
        touchpad = {
          clickMethod = "clickfinger";
          naturalScrolling = true;
          disableWhileTyping = true;
        };
      };
      resolved = {
        enable = true;
        fallbackDns = [ ]; # disable fallback DNS
        dnsovertls = "true";
        dnssec = "true";
        llmnr = "false"; # For security
      };
      scx = {
        enable = true;
        package = pkgs.scx.rustscheds;
        scheduler = "scx_lavd"; # Scheduler that minimizes latency and reduces power usage
        extraArgs = [ "--autopower" ]; # Adjust power mode based on system EPP
      };
      upower = {
        enable = true;
        percentageLow = 30;
        percentageCritical = 10;
        # Disable polling for hardware that pushes events
        noPollBatteries = true;
      };
    };

    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      };
      terminal-exec = {
        enable = true;
        settings.default = [ "foot.desktop" ];
      };
    };

    programs = {
      bash.blesh.enable = true;
      xwayland.enable = true;
    };

    environment.sessionVariables = {
      # Enable running commands without installation
      # Currently not needed because nix-index is enabled in home-manager
      # NIX_AUTO_RUN = "1";
      # Make Electron apps run in Wayland native mode
      NIXOS_OZONE_WL = "1";
    };
  };
}
