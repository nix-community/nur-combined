{config, ...}: {
  imports = [
    ./alacritty.nix
    ./bat.nix
    ./direnv.nix
    ./emacs.nix
    ./env.nix
    ./firefox.nix
    ./fish
    ./flameshot.nix
    ./git.nix
    ./gtk.nix
    ./jj.nix
    ./laptop.nix
    ./mail.nix
    ./rbw.nix
    ./rofi.nix
    ./ssh.nix
    ./themes
    ./tmux.nix
    ./tridactyl.nix
    ./x
  ];

  home.username = "alarsyo";

  home.sessionVariables = let
    gpgPackage = config.programs.gpg.package;
  in {
    BROWSER = "firefox";
    # FIXME: only set if gpg-agent not in use, otherwise home manager already does that
    SSH_AUTH_SOCK = "$(${gpgPackage}/bin/gpgconf --list-dirs agent-ssh-socket)";
    XDG_DATA_HOME = "$HOME/.local/share";
  };
}
