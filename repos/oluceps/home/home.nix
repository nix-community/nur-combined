{
  config,
  pkgs,
  lib,
  user,
  osConfig,
  ...
}:

let
  baseModule = [
    "atuin"
    "tmux"
    "helix"
    "nu"
    "btop"
    "hyfetch"
    "starship"
    "direnv"
  ];

  fullModule = (
    with builtins;
    attrNames (
      lib.filterAttrs (n: _: !elem n [ "hyprland" ]) # one or more of them conflict with gnome  "sway" "hyprland" "waybar"
        (readDir ./programs)
    )
  );

  optionalGraphicComponents = lib.optionals osConfig.security.rtkit.enable; # is there a better way to identify fancy machine
in
{
  imports =
    let
      canonicalizedModule = (lib.unique (baseModule ++ optionalGraphicComponents fullModule));
    in
    (map (d: ./programs + d) (map (n: "/" + n) canonicalizedModule))
    ++ optionalGraphicComponents [ ./graphBase.nix ];
  home = {
    stateVersion = "22.11";
    username = user;
    homeDirectory = "/home/${user}";
    file.".ssh/config".source = config.lib.file.mkOutOfStoreSymlink "/run/agenix/ssh-cfg";
    sessionVariables = {
      EDITOR = "hx";
    };

    file.".blerc".text = ''
      bleopt term_true_colors=none
      bleopt prompt_ruler=empty-line
      ble-face -s command_builtin_dot       fg=yellow,bold
      ble-face -s command_builtin           fg=yellow
      ble-face -s filename_directory        underline,fg=magenta
      ble-face -s filename_directory_sticky underline,fg=white,bg=magenta
      ble-face -s command_function          fg=blue

      function ble/prompt/backslash:my/starship-right {
        local right
        ble/util/assign right '${pkgs.starship}/bin/starship prompt --right'
        ble/prompt/process-prompt-string "$right"
      }
      bleopt prompt_rps1="\n\n\q{my/starship-right}"
      bleopt prompt_ps1_final="\033[1m=>\033[0m "
      bleopt prompt_rps1_transient="same-dir"
    '';
  };

  systemd.user = {
    sessionVariables = {
      CARGO_REGISTRIES_CRATES_IO_PROTOCOL = "sparse";
      CARGO_UNSTABLE_SPARSE_REGISTRY = "true";
      NEOVIDE_MULTIGRID = "1";
      NEOVIDE_WM_CLASS = "1";
      NODE_PATH = "~/.npm-packages/lib/node_modules";
    };
  };

  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };
  programs = {
    yazi.enable = true;
    jq.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
      package = pkgs.gitFull;
      userName = "oluceps";
      userEmail = "i@oluceps.uk";
      extraConfig = {
        # user.signingKey = "/run/agenix/id_sk";
        tag.gpgsign = true;
        core.editor = with pkgs; (lib.getExe helix);
        commit.gpgsign = true;
        gpg = {
          format = "ssh";
          ssh.defaultKeyCommand = "ssh-add -L";
          ssh.allowedSignersFile = toString (pkgs.writeText "allowed_signers" "");
        };
        merge.conflictStyle = "diff3";
        merge.tool = "vimdiff";
        mergetool = {
          keepBackup = false;
          keepTemporaries = false;
          writeToTemp = true;
        };
        pull.rebase = true;
        fetch.prune = true;
        http.postBuffer = 524288000;
        ssh.postBuffer = 524288000;
        sendemail = {
          smtpserver = "smtp.gmail.com";
          smtpencryption = "tls";
          smtpserverport = 587;
          smtpuser = "mn1.674927211@gmail.com";
          from = "mn1.674927211@gmail.com";
        };
      };
    };

    home-manager.enable = true;
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [
        "--height 80%"
        "--layout=reverse"
        "--info=inline"
        "--border"
        "--exact"
      ];
    };
  };

  services = {
    gpg-agent = {
      enable = false;
      defaultCacheTtl = 1800;
      enableSshSupport = false;
    };
  };

  home.packages = with pkgs; [ atuin ];
}
