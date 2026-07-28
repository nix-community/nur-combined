{ vaculib, ... }: {
  systemd.tmpfiles.settings.whatever = {
    "/var/lib/fdroid-repo".d = {
      user = "shelvacu";
      group = "root";
      mode = vaculib.accessModeStr {
        user = "all";
        all = {
          read = true;
          execute = true;
        };
      };
    };
    "/var/lib/fdroid-repo".A.argument = "u::rwX,g::,o::rX,d:u::rwX,d:g::,d:o::rX";
  };

  services.caddy.virtualHosts."fdroid.shelvacu.com" = {
    vacu.hsts = "preload";
    extraConfig = ''
      root * /var/lib/fdroid-repo
      file_server
    '';
  };
}
