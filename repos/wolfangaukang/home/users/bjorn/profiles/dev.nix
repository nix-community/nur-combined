{ config, ... }:

{
  programs = {
    git = {
      enable = true;
      extraConfig = {
        # FIXME: Create reference to identity key on ssh settings
        core.sshCommand = "ssh -i ${config.home.homeDirectory}/.ssh/Keys/id";
        init.defaultBranch = "main";
      };
      signing = {
        # FIXME: Make me private
        key = "F90110C7";
        signByDefault = true;
      };
      # FIXME x2: Make me private
      userName = "P. R. d. O.";
      userEmail = "d.ol.rod@tutanota.com";
    };
    gpg.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
  services = {
    gpg-agent = {
      enable = true;
      # FIXME: Check my purpose
      enableScDaemon = false;
      pinentryFlavor = "curses";
    };
  };
}
