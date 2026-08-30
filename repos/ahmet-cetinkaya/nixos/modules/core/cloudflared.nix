{pkgs, ...}: {
  systemd.services.cloudflared = {
    description = "Cloudflare Tunnel daemon";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "notify";
      User = "cloudflared";
      Group = "cloudflared";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;

      LoadCredential = "tunnel-token:/var/lib/secrets/cloudflared-tunnel-token";
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel run --token-file %d/tunnel-token";

      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  users.users.cloudflared = {
    isSystemUser = true;
    group = "cloudflared";
  };

  users.groups.cloudflared = {};
}
