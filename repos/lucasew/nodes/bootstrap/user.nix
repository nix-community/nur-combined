{global, config, pkgs, ...}:
let
  inherit (global) username;
  inherit (pkgs) writeText;
  lecture = writeText "sudo-lecture" ''
Acha que é assim fácil?
  '';
in {
  sops.secrets.admin-password = {
    sopsFile = ../../secrets/admin-password;
    group = config.users.groups.admin-password.name;
    format = "binary";
    mode = "0440";
  };
  users.groups.admin-password = {};

  users.users = {
    ${username} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        # "podman"
        "docker"
        "video"
        "render"
        "transmission"
      ];
      passwordFile = "/var/run/secrets/admin-password";
      openssh.authorizedKeys.keyFiles = [
        ../../authorized_keys
      ];
    };
  };
  security.sudo.extraConfig = ''
Defaults lecture = always

Defaults lecture_file=${lecture}
  '';
}
