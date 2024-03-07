# Google Laptop configuration
{ lib, options, pkgs, ... }:
{
  services.gpg-agent.enable = lib.mkForce false;

  my.home = {
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
