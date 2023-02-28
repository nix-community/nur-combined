{ global, config, pkgs, lib, ...}:
let
  inherit (global) username;
in {
  sops.secrets.admin-password = {
    sopsFile = ../../secrets/admin-password;
    group = config.users.groups.admin-password.name;
    format = "binary";
    mode = "0440";
  };
  users.groups.admin-password = {};

  users.users.${username} = {
    passwordFile = "/var/run/secrets/admin-password";
  };

}
