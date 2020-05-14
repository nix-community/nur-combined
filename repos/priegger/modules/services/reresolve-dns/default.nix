{ config, pkgs, lib, makeWrapper, ... }:

with lib;
let
  reresolveDns = pkgs.callPackage ./pkg.nix { };

  cfg = config.priegger.services.reresolve-dns;
in
{
  options.priegger.services.reresolve-dns = {
    enable = mkEnableOption "update kernel DNS entries for wireguard remote endpoints";

    interval = mkOption {
      type = types.str;
      default = "minutely";
      description = ''
        The interval at which to trigger a DNS update.
        Valid values must conform to systemd.time(7) format.
      '';
    };
  };

  config = mkIf cfg.enable {

    systemd.timers.reresolve-dns = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.interval;
      };
    };

    systemd.services.reresolve-dns = {
      description = "re-resolve wireguard dns endpoints";

      path = [ reresolveDns pkgs.coreutils pkgs.gnugrep ];

      script = ''
        set -x
        script="$(grep '^ExecStart=' /etc/systemd/system/wg-quick-wg0.service | cut -d '=' -f 2 | sed -e 's/ //g')"
        config="$(grep '^wg-quick' "$script" | tr ' ' '\n' | grep '.conf$')"
        reresolve-dns "$config"
      '';
    };
  };
}
