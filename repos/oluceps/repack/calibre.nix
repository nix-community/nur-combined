{
  reIf,
  pkgs,
  lib,
  ...
}:
reIf {
  users.groups.calibre = {};
  services = {
    calibre-server = {
      enable = true;
      port = 8082;
      group = "calibre";
      auth = {
        enable = true;
        userDb = "/var/lib/calibre-server/users.sqlite";
      };
    };
    # calibre-web = {
    #   enable = true;
    #   group = "calibre";
    #   options.calibreLibrary = "/var/lib/calibre-server";
    # };
  };
}
