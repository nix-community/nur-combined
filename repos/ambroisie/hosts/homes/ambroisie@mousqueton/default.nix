# Google Cloudtop configuration
{ lib, pkgs, ... }:
{
  # Google specific configuration
  home.homeDirectory = "/usr/local/google/home/ambroisie";

  services.gpg-agent.enable = lib.mkForce false;

  my.home = {
    git = {
      package = pkgs.emptyDirectory;
    };

    tmux = {
      # I use scripts that use the passthrough sequence often on this host
      enablePassthrough = true;

      # Frequent reboots mean that session persistence can be handy
      enableResurrect = true;

      terminalFeatures = {
        # HTerm uses `xterm-256color` as its `$TERM`, so use that here
        xterm-256color = { };
      };
    };
  };
}
