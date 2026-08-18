# NixOS module for the USB passthrough agent.
#
# `mlos-host-utils install` is the wrong command on NixOS: it installs a
# usbip package with the system package manager, writes a unit into
# /etc/systemd/system and edits the firewall, and a rebuild undoes the parts
# of that NixOS considers its own.  This module does the same four things
# declaratively, so they survive.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.mlos-host-utils;

  # The pairing code is generated state, not configuration, so it belongs in
  # /var/lib rather than the default /etc/mlos-host-utils.  Both the service
  # and anyone running `mlos-host-utils pair` have to look in the same place
  # -- if they disagree, the CLI quietly mints a second token and the code on
  # screen is not the one the agent will accept.
  stateDir = "/var/lib/mlos-host-utils";
in
{
  options.services.mlos-host-utils = {
    enable = lib.mkEnableOption "the Moonlight OS USB passthrough agent";

    package = lib.mkPackageOption pkgs "mlos-host-utils" { };

    port = lib.mkOption {
      type = lib.types.port;
      default = 48020;
      description = "TCP port the agent listens on for its paired Moonlight OS client.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Open {option}`services.mlos-host-utils.port` in the firewall.

        Anything that can reach the port and has the pairing code can attach
        USB devices from its own machine to this one, so this is off by
        default -- open it deliberately, and preferably only on the interface
        the thin client is on.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # vhci-hcd is the virtual host controller that makes a remote device show
    # up as a local one.  Without it every attach fails with a message about
    # /sys/devices/platform/vhci_hcd that explains nothing.
    boot.kernelModules = [ "vhci-hcd" ];

    environment.systemPackages = [ cfg.package ];

    # So that `mlos-host-utils pair` in a terminal reads the same token the
    # service is serving.
    environment.variables.MLOS_HOST_UTILS_DIR = stateDir;

    systemd.services.mlos-host-utils = {
      description = "Moonlight OS host utils (USB/IP passthrough agent)";
      documentation = [ "https://github.com/MopigamesYT/moonlight-os" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      # usbip is versioned against the running kernel, so it comes from the
      # kernel package set rather than the top level.
      path = [ config.boot.kernelPackages.usbip ];

      environment.MLOS_HOST_UTILS_DIR = stateDir;

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} run --port ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = 3;
        StateDirectory = "mlos-host-utils";
        StateDirectoryMode = "0700";
      };
      # Attaching a device is a write to /sys and a modprobe, so this runs as
      # root.  It is not hardened further here: the sandboxing options that
      # would matter (ProtectKernelModules, PrivateDevices) are exactly the
      # ones that stop it working.
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
