{
  lib,
  config,
  pkgs,
  vaculib,
  ...
}:
let
  mcfg = config.services.murmur;
  caddyCertDir = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/mumble.shelvacu.com";
  murmurCertDir = "${mcfg.stateDir}/certs";
in
{
  services.murmur = {
    enable = true;
    openFirewall = true;
    # bonjour = true;
    bandwidth = 10 * 1000 * 1000;
    logDays = 0; # forever
    allowHtml = false;
    sslCert = "${murmurCertDir}/ssl.crt";
    sslKey = "${murmurCertDir}/ssl.key";
  };

  systemd.services.murmur = {
    wants = [ "check-murmur-cert.service" ];
    before = [ "check-murmur-cert.service" ];
    serviceConfig = {
      ExecReload = "${pkgs.util-linux}/bin/kill -SIGUSR1 $MAINPID";
      SocketBindAllow = [
        "ipv4:${toString mcfg.port}"
        "ipv6:${toString mcfg.port}"
      ];
      SocketBindDeny = "any";
    };
  };

  systemd.tmpfiles.settings.whatever."${murmurCertDir}".d = {
    inherit (mcfg) user group;
    mode = vaculib.accessModeStr { user = "all"; };
  };

  systemd.services.check-murmur-cert = {
    enable = true;
    enableStrictShellChecks = true;
    script = ''
      set -euo pipefail
      caddyCertDir=${lib.escapeShellArg caddyCertDir}
      murmurCertDir=${lib.escapeShellArg murmurCertDir}
      function getModified() {
        declare dir="$1" cert nullglobRestore
        shift

        nullglobRestore="$(shopt -p nullglob)"
        shopt -s nullglob
        cert="$(echo "$dir"/*.crt)"
        $nullglobRestore

        if [[ -z $cert ]]; then
          printf "0000\n"
        else
          date --utc --iso-8601=seconds --reference="$cert"
        fi;
        return 0
      }
      echo "Checking if cert has changed"
      if [[ $(getModified "$caddyCertDir") > $(getModified "$murmurCertDir") ]]; then
        echo "Change detected, copying files..."
        installCmd=(
          install
          --no-target-directory
          --owner ${lib.escapeShellArg mcfg.user}
          --group ${lib.escapeShellArg mcfg.group}
          --mode ${
            vaculib.accessMode {
              user = "all";
            }
          }
          --preserve-timestamps
          --verbose
        )
        "''${installCmd[@]}" "$caddyCertDir"/*.crt "$murmurCertDir"/ssl.crt
        "''${installCmd[@]}" "$caddyCertDir"/*.key "$murmurCertDir"/ssl.key
        echo "Reloading murmur"
        systemctl try-reload-or-restart murmur
        echo "Done"
      else
        echo "No change detected"
      fi
    '';
  };

  systemd.timers.check-murmur-cert = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    timerConfig.RandomizedDelaySec = "5s";
    timerConfig.OnUnitInactiveSec = "1h";
    timerConfig.OnActiveSec = "0s";
  };

  environment.persistence."/persistent".directories = [
    {
      directory = mcfg.stateDir;
      inherit (mcfg) user group;
      mode = vaculib.accessModeStr { user = "all"; };
    }
  ];

  # just for the ssl cert
  services.caddy.virtualHosts."mumble.shelvacu.com" = {
    vacu.hsts = "preload";
    extraConfig = ''
      header Content-Type text/html
      respond 200 {
        body <<EOF
          You'll want to use a <a href="https://www.mumble.info/downloads/">mumble client</a> to connect.
        EOF
        close
      }
    '';
  };
}
