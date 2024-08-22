{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = false;

    sessionVariables = {
      BROWSER = "firefox";
      EDITOR = "vim";
      COLORTERM = "truecolor";
    };

    shellAliases = {

      open = "xdg-open";
      t = "tmux a || smug start lobby && smug start doen && smug start sudo && smug start nixos && smug start tekst";
      lin = "vim -c LinnyStart";
      nlin = "nvim -c LinnyStart /home/pim/secondbrain/wikiContent/doen_werk.md";
      tn = "tmux new -d -s";
      tmxa = "tmux unbind C-a && tmux set-option -g prefix C-a && tmux bind-key C-a send-prefix";
      tmxb = "tmux unbind C-b && tmux set-option -g prefix C-b && tmux bind-key C-b send-prefix";
      smugs = "smug start doen && smug start sudo && smug start nixos && smug start lobby";
      smugs_q = "smug start quiqr_dev_run && smug start quiqr_data";
      smugs_tn = "smug start technative_aws && smug start technative_docs && smug start technative_weare";

      crb_status = "mount | grep /mnt/cryptobox";
      crb_mount = "crb_status || sudo cryptobox --mount /home/pim/Nextcloud/Vaults/keys.luks.ext4.img /mnt/cryptobox";
      crb_umount = "sudo umount /mnt/cryptobox";
      crb_diff = "diff -qr ~/.aws /mnt/cryptobox/encrypim/.aws; diff -qr ~/.ssh /mnt/cryptobox/encrypim/.ssh";

      # technative
      tn_aws_mfa = "aws-mfa --profile technative --device arn:aws:iam::521402697040:mfa/pim@technative.nl";

      # adevinta
      ffadevinta = "MOZ_ENABLE_WAYLAND=0 proxychains4 firefox -P adevinta --class ffextra --no-remote";
      adeff = "MOZ_ENABLE_WAYLAND=0 proxychains4 firefox -P adevinta --class ffextra --no-remote";
      adedsocksamf = "ssh -D 9050 pim.snel@192.168.0.139";
      adedsockshur = "ssh -D 9050 pim.snel@192.168.13.26";
      adedmoshamf = "mosh pim.snel@192.168.0.139 --server=/usr/local/bin/mosh-server";

      sshpw = "ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password";

      hm_reset_envs = "unset __HM_SESS_VARS_SOURCED __HM_ZSH_SESS_VARS_SOURCED && source ~/.zshenv";
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
      theme = "pim";
      custom = "$HOME/.ohmyzsh-pim";
      plugins=["git kubectl terraform aws"];
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

