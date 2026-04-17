{
  flake.modules.nixos.calibre = {
    users.groups.calibre = { };
    services.calibre-web = {
      enable = true;
      group = "calibre";
      listen.ip = "fdcc::3";
      options = {
        calibreLibrary = "/var/lib/calibre";
        enableBookUploading = true;
        reverseProxyAuth.enable = true;
      };
    };
  };
}
