{global, pkgs, ...}:
let
  inherit (global) username;
  inherit (pkgs) writeText;
  lecture = writeText "sudo-lecture" ''
Acha que é assim fácil?
  '';
in {
  users.users = {
    ${username} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "podman"
      ];
      initialPassword = "changeme";
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
