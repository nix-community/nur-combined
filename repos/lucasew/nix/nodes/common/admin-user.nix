{ config, ... }:

{
  sops.secrets.admin-password = {
    sopsFile = ../../secrets/admin-password;
    group = config.users.groups.admin-password.name;
    format = "binary";
    mode = "0440";
  };

  users.groups.admin-password = { };
}
