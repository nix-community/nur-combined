{ config, pkgs, ... }:
{
  systemd.services.githubstarsmanager = {
    description = "GithubStarsManager - AI-powered GitHub stars manager (fullstack)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    environment = {
      NODE_ENV = "production";
      PORT = "3000";
      STATIC_DIR = "${pkgs.githubstarsmanager}/public";
      HTTPS_PROXY = config.networking.proxy.default;
    };

    serviceConfig = {
      ExecStart = "${pkgs.nodejs_22}/bin/node ${pkgs.githubstarsmanager}/dist/index.js";
      WorkingDirectory = "/var/lib/githubstarsmanager";
      StateDirectory = "githubstarsmanager";
      DynamicUser = true;
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
