# Interactive graphical session
{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.profiles.graphical;
in

{
  imports = [ ./base.nix ];

  options.abszero.profiles.graphical.enable = mkExternalEnableOption config "graphical profile";

  config = mkIf cfg.enable {
    abszero = {
      profiles.base.enable = true;
      boot.lanzaboote.enable = true;
      services.pipewire.enable = true;
    };

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

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
      kmscon = {
        enable = true;
        hwRender = true;
        extraConfig = ''
          # Input
          xkb-repeat-rate=40
          xkb-repeat-delay=160
          # mouse TODO: enable mouse support when it lands

          # Appearance
          font-size=18
          palette=base16-light
        '';
      };
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
        settings.Resolve = {
          FallbackDNS = []; # Disable fallback DNS
          DNSOverTLS = "true";
          DNSSEC = "true";
          LLMNR = "false"; # For security
        };
      };
      scx = {
        enable = true;
        package = pkgs.scx.rustscheds;
        scheduler = "scx_lavd"; # Scheduler that minimizes latency and reduces power usage
      };
    };

    xdg.terminal-exec = {
      enable = true;
      settings.default = [ "foot.desktop" ];
    };

    programs = {
      bash.blesh.enable = true;
      xwayland.enable = true;
    };

    # Make Electron apps run in Wayland native mode
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
