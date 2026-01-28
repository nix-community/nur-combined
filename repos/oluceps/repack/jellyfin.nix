{ reIf, pkgs, ... }:
reIf {
  services.jellyfin = {
    enable = true;
    openFirewall = true;
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
}
