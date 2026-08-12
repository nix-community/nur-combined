{
  global,
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
  inherit (global) username;
  inherit (pkgs) writeText;
  lecture = writeText "sudo-lecture" ''
    Acha que é assim fácil?
  '';
in
{
  services.displayManager.autoLogin = {
    enable = lib.mkDefault true;
    user = lib.mkDefault username;
  };

  users = {
    mutableUsers = true;
    users = {
      ${username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          # "podman"
          "docker"
          "video"
          "render"
          "ssh"
        ];
        initialPassword = "changeme";
      };
    };
  };
  security.sudo.extraConfig = ''
    Defaults lecture = always

    Defaults lecture_file=${lecture}
  '';
}
