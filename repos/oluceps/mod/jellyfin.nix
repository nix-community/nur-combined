{
  flake.modules.nixos.jellyfin =
    { config, pkgs, ... }:
    {
      services.jellyfin = {
        enable = true;
        openFirewall = false;
      };
      realm.workloads.jellyfin = {
        ingress.http = {
          port = 18096;
          backend = {
            kind = "private-tcp";
            port = 8096;
          };
          service = "jellyfin";
          allow.identities = config.realm.caddy.allowedIDs.jellyfin;
        };
        http.internet = true;
      };
      systemd.services.jellyfin.environment = {
        JELLYFIN_PublishedServerUrl = "https://jellyfin.nyaw.xyz";
      };
      environment.systemPackages = [
        pkgs.jellyfin
        pkgs.jellyfin-web
        pkgs.jellyfin-ffmpeg
      ];
      systemd.services.jellyfin.serviceConfig.SupplementaryGroups = [ "rqbit" ];
      nixpkgs.overlays = [
        (final: prev: {
          jellyfin-web = prev.jellyfin-web.overrideAttrs (
            finalAttrs: previousAttrs: {
              installPhase = ''
                runHook preInstall
                sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html
                mkdir -p $out/share
                cp -a dist $out/share/jellyfin-web
                runHook postInstall
              '';
            }
          );
        })
      ];
    };
}
