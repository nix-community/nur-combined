{ pkgs, ... }: {
  vacu.copyparties.dwabtit = {
    enable = true;
    domain = "dwabtit.shelvacu.com";
    oauthInstance = "dwabtit";
    volumes = {
      "/" = {
        hostPath = pkgs.emptyDirectory;
        access = "r: shelvacu";
      };
      "/a" = {
        hostPath = "/propdata/trip/ffuts/archive";
        access = "r: shelvacu";
      };
    };
  };
  vacu.oauthProxy.instances.dwabtit = {
    displayName = "Don't worry about it.";
    kanidmMembers = [ "shelvacu" ];
  };
  services.caddy.virtualHosts."dwabtit.shelvacu.com".vacu.hsts = "preload";
}
