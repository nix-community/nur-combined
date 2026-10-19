{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ddns.desec;
  desec = pkgs.writeShellScriptBin "desec-ddns" ''
    # Use the deSEC dynDNS API to update a domain's A/AAAA records
    echo "Updating DNS record via deSEC"

    RESPONSE=$(curl -sS --max-time 60 --no-progress-meter \
      -u "$DESEC_DOMAIN:$DESEC_TOKEN" \
      "https://update.dedyn.io/?hostname=$DESEC_DOMAIN")

    if [[ "$RESPONSE" == "good"* ]] || [[ "$RESPONSE" == "nochg"* ]]; then
      echo "deSEC request at $(date) succeeded: $RESPONSE"
    else
      echo "Failed to update deSEC record. Response: $RESPONSE"
      exit 1
    fi
  '';
in
{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.tokenFile != null;
        message = "ddns.desec.tokenFile has to be defined";
      }
    ];

    environment.systemPackages = [ desec ];

    systemd.services.desec-ddns = {
      description = "deSEC Dynamic DNS Client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      startAt = "*:0/5";
      path = [
        pkgs.curl
        desec
      ];
      serviceConfig = {
        Type = "simple";
        LoadCredential = [
          "DESEC_TOKEN_FILE:${cfg.tokenFile}"
        ];
        DynamicUser = true;
      };
      script = ''
        export DESEC_TOKEN=$(systemd-creds cat DESEC_TOKEN_FILE)
        export DESEC_DOMAIN=${cfg.domain}
        ${desec}/bin/desec-ddns
      '';
    };
  };

  # meta.maintainers = with lib.maintainers; [avycado13];
}
