{
  pkgs,
  ...
}:
{
  nix.settings.trusted-users = [ "avy" ];
  programs.zsh.enable = true;

  # age.secrets.hashedUserPassword = {
  #   file = "${inputs.secrets}/hashedUserPassword.age";
  # };

  users = {
    users = {
      avy = {
        shell = pkgs.zsh;
        uid = 1000;
        isNormalUser = true;
        # hashedPasswordFile = config.age.secrets.hashedUserPassword.path;
        extraGroups = [
          "wheel"
          "users"
          "video"
          "podman"
          "input"
        ];
        group = "avy";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPm9/uwsYQ2KrzaVcpulcDUKnBOCMCYogfC+D+TcrK7"
        ];
      };
    };
    groups = {
      avy = {
        gid = 1000;
      };
    };
  };
}
