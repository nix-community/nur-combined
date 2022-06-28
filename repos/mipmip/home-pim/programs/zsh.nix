{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autocd = true;
    enableAutosuggestions = false;

    sessionVariables = {

      BROWSER = "firefox";
      EDITOR = "vim";

    };

    shellAliases = {
      open = "xdg-open";
      t = "tmux a || smug start lobby && smug start doen && smug start sudo && smug start nixos && smug start tekst";
      tn = "tmux new -d -s";
      smugs = "smug start doen && smug start sudo && smug start nixos && smug start tekst && smug start ssh-killerberg";
    };

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.4.0";
          sha256 = "037wz9fqmx0ngcwl9az55fgkipb745rymznxnssr3rx9irb6apzg";
        };
      }
    ];

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins=["git" "docker" "docker-compose"];
    };

    initExtra = ''
      if [[ -n "$IN_NIX_SHELL" ]]; then
        label="nix-shell"
        if [[ "$name" != "$label" ]]; then
          label="$label:$name"
        fi
        export PS1=$'%{$fg[green]%}'"$label$PS1"
        unset label
      fi
      '';
  };
}
