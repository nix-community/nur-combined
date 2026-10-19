{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ddns.cloudflare;
  cloudflare = pkgs.writeShellScriptBin "cloudflare-ddns" ''
    # Use Cloudflare API to update DNS records
    echo "Updating DNS records via Cloudflare API"

    # Get current IP
    CURRENT_IP=$(curl -sS --max-time 60 --no-progress-meter https://ipinfo.io/ip)
    if [ -z "$CURRENT_IP" ]; then
      echo "Failed to get current IP address"
      exit 1
    fi

    # Get Cloudflare zone and record details
    ZONE_ID="$CLOUDFLARE_ZONE_ID"
    RECORD_NAME="$CLOUDFLARE_RECORD_NAME"
    API_TOKEN="$CLOUDFLARE_API_TOKEN"

    # Get the record ID from Cloudflare
    RECORD_ID=$(curl -sS -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$RECORD_NAME" \
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" | grep -oP '(?<="id":")[^"]*')

    if [ -z "$RECORD_ID" ]; then
      echo "Failed to get record ID for $RECORD_NAME"
      exit 1
    fi

    # Update the DNS record
    RESPONSE=$(curl -sS -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"A\",\"name\":\"$RECORD_NAME\",\"content\":\"$CURRENT_IP\",\"ttl\":120,\"proxied\":false}")

    if echo "$RESPONSE" | grep -q '"success":true'; then
      echo "DNS record updated successfully at $(date) to IP: $CURRENT_IP"
    else
      echo "Failed to update DNS record. Response: $RESPONSE"
    fi
  '';
in
{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.apiTokenFile != null;
        message = "ddns.cloudflare.apiTokenFile has to be defined";
      }
      {
        assertion = cfg.zoneId != null;
        message = "ddns.cloudflare.zoneId has to be defined";
      }
      {
        assertion = cfg.recordName != null;
        message = "ddns.cloudflare.recordName has to be defined";
      }
    ];

    environment.systemPackages = [ cloudflare ];

    systemd.services.cloudflare-ddns = {
      description = "Cloudflare Dynamic DNS Client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      startAt = "*:0/5";
      path = [
        pkgs.curl
        pkgs.grep
        cloudflare
      ];
      serviceConfig = {
        Type = "simple";
        LoadCredential = [
          "CLOUDFLARE_API_TOKEN_FILE:${cfg.apiTokenFile}"
        ];
        DynamicUser = true;
      };
      script = ''
        export CLOUDFLARE_API_TOKEN=$(systemd-creds cat CLOUDFLARE_API_TOKEN_FILE)
        export CLOUDFLARE_ZONE_ID=${cfg.zoneId}
        export CLOUDFLARE_RECORD_NAME=${cfg.recordName}
        ${cloudflare}/bin/cloudflare-ddns
      '';
    };
  };

  # meta.maintainers = with lib.maintainers; [avycado13];
}
