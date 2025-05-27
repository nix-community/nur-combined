# Google Cloudtop configuration
{ lib, pkgs, ... }:
{
  # Google specific configuration
  home.homeDirectory = "/usr/local/google/home/ambroisie";

  services.gpg-agent.enable = lib.mkForce false;

  my.home = {
    atuin = {
      package = pkgs.stdenv.mkDerivation {
        pname = "atuin";
        version = "18.4.0";

        buildCommand = ''
          mkdir -p $out/bin
          ln -s /usr/bin/atuin $out/bin/atuin
        '';

        meta.mainProgram = "atuin";
      };
    };

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
