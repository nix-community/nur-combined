# Google Laptop configuration
{ lib, options, pkgs, ... }:
{
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

      terminalFeatures = {
        # HTerm uses `xterm-256color` as its `$TERM`, so use that here
        xterm-256color = { };
      };
    };

    ssh = {
      mosh = {
        package = pkgs.emptyDirectory;
      };
    };

    zsh = {
      notify = {
        enable = true;

        exclude = options.my.home.zsh.notify.exclude.default ++ [
          "adb shell$" # Only interactive shell sessions
        ];

        ssh = {
          enable = true;
          # `notify-send` is proxied to the ChromeOS layer
          useOsc777 = false;
        };
      };
    };
  };
}
