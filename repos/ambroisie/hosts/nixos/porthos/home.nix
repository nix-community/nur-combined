{ ... }:
{
  my.home = {
    # Allow using 24bit color when SSH-ing from various clients
    tmux.trueColorTerminals = [
      # My usual terminal, e.g: on laptop
      "alacritty"
    ];

    # Always start a tmux session when opening a shell session
    zsh.launchTmux = true;
  };
}
