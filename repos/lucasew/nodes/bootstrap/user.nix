{global, config, pkgs, lib, ...}:
let
  inherit (lib) mkDefault;
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
        # "podman"
        "docker"
        "video"
        "render"
        "transmission"
      ];
      passwordFile = mkDefault (builtins.toFile "default-password" "changeme");
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
