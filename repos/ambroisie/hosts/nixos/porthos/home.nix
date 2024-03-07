{ ... }:
{
  my.home = {
    nix = {
      cache = {
        # This server is the one serving the cache, don't try to query it
        selfHosted = false;
      };
    };

    # Allow using extended features when SSH-ing from various clients
    tmux.terminalFeatures = {
      # My usual terminal, e.g: on laptop
      alacritty = { };
    };

    # Always start a tmux session when opening a shell session
    zsh.launchTmux = true;
  };
}
