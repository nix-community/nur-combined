{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ddns.freedns;
  freedns = pkgs.writeShellScriptBin "freedns-ddns" ''
    # Use FreeDNS (afraid.org) to update a dynamic DNS record
    echo "Updating DNS record via FreeDNS"

    RESPONSE=$(curl -sS --max-time 60 --no-progress-meter "$FREEDNS_UPDATE_URL")

    if echo "$RESPONSE" | grep -qiE "^(Updated|ERROR: Address .* has not changed)"; then
      echo "FreeDNS request at $(date) succeeded: $RESPONSE"
    else
      echo "Failed to update FreeDNS record. Response: $RESPONSE"
      exit 1
    fi
  '';
in
{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.updateUrlFile != null;
        message = "ddns.freedns.updateUrlFile has to be defined";
      }
    ];

    environment.systemPackages = [ freedns ];

    systemd.services.freedns-ddns = {
      description = "FreeDNS Dynamic DNS Client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      startAt = "*:0/5";
      path = [
        pkgs.curl
        pkgs.gnugrep
        freedns
      ];
      serviceConfig = {
        Type = "simple";
        LoadCredential = [
          "FREEDNS_UPDATE_URL_FILE:${cfg.updateUrlFile}"
        ];
        DynamicUser = true;
      };
      script = ''
        export FREEDNS_UPDATE_URL=$(systemd-creds cat FREEDNS_UPDATE_URL_FILE)
        ${freedns}/bin/freedns-ddns
      '';
    };
  };

  # meta.maintainers = with lib.maintainers; [avycado13];
}
