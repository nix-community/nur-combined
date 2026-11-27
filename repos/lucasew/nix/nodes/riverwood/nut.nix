{ config, lib, ... }:
{
  # Shared with whiterun (secondary upsmon) and HA (read-only user).
  sops.secrets.nut-upsmon-primary-password = {
    sopsFile = ../../../secrets/nut.yaml;
    key = "upsmon_primary_password";
  };
  sops.secrets.nut-whiterun-password = {
    sopsFile = ../../../secrets/nut.yaml;
    key = "whiterun_secondary_password";
  };
  sops.secrets.nut-ha-password = {
    sopsFile = ../../../secrets/nut.yaml;
    key = "homeassistant_password";
  };

  power.ups = {
    enable = true;
    mode = "netserver";

    ups.itaipu2 = {
      driver = "sms_ser";
      port = "/dev/serial/by-id/usb-Prolific_Technology_Inc._USB-Serial_Controller_DKCRb11CN11-if00-port0";
    };

    users = {
      # Local upsmon (primary on the machine that owns the driver).
      upsmon = {
        passwordFile = config.sops.secrets.nut-upsmon-primary-password.path;
        upsmon = "primary";
      };
      # Whiterun's upsmon connects from the network as secondary.
      whiterun = {
        passwordFile = config.sops.secrets.nut-whiterun-password.path;
        upsmon = "secondary";
      };
      # Read-only: no actions/instcmds. NUT allows anonymous reads, but HA
      # gets its own credential instead of sharing upsmon's.
      homeassistant = {
        passwordFile = config.sops.secrets.nut-ha-password.path;
      };
    };

    upsmon.monitor.itaipu2 = {
      user = "upsmon";
      type = "primary";
    };

    # nixpkgs leaves upsd.conf without LISTEN lines, so NUT only binds
    # loopback. HA is local; whiterun reaches this over Tailscale, and the
    # firewall rule keeps 3493 off the LAN.
    upsd.listen = [
      {
        address = "0.0.0.0";
      }
    ];
  };

  # 3493 stays off the LAN; only whiterun (the machine on the UPS) may talk
  # to upsd over the tailnet. HA connects over loopback.
  networking.firewall.extraInputRules = ''
    ip saddr 100.85.38.19 tcp dport 3493 accept
  '';

  # nixpkgs starts upsd before the driver and does not restart it when
  # ups.conf changes, so it keeps the old socket path.
  systemd.services.upsdrv = {
    after = lib.mkForce [ "local-fs.target" ];
    before = [ "upsd.service" ];
  };
  systemd.services.upsd = {
    after = [ "upsdrv.service" ];
    restartTriggers = [ config.environment.etc."nut/ups.conf".source ];
  };
}
