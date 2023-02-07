{ config, pkgs, ... }:
let
  inherit (pkgs) fetchFromGitHub;
  inherit (pkgs.lib.attrsets) recursiveUpdate;
  batAlias = if config.programs.bat.enable then {
    less = "${pkgs.bat}/bin/bat --color always";
  } else
    { };
  mergeAliases = [ batAlias ];
  shellAliases = builtins.foldl' recursiveUpdate { } mergeAliases;
in {
  programs.zsh = {
    inherit shellAliases;
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    enableVteIntegration = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
      theme = "risto";
    };
    plugins = [{
      name = "zsh-nix-shell";
      file = "nix-shell.plugin.zsh";
      src = fetchFromGitHub {
        owner = "chisui";
        repo = "zsh-nix-shell";
        rev = "v0.5.0";
        sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
      };
    }
    # {
    #   name = "jq-zsh-plugin";
    #   file = "jq.plugin.zsh";
    #   src = fetchFromGitHub {
    #     owner = "reegnz";
    #     repo = "jq-zsh-plugin";
    #     rev = "v0.4.0";
    #     sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
    #   };
    # }
    # {
    #   name = "zsh-ssh";
    #   file = "zsh-ssh.zsh";
    #   src = fetchFromGitHub {
    #     owner = "sunlei";
    #     repo = "zsh-ssh";
    #     rev = "d3b8ce35a0ad3cbfaecb31d9535af270c6ff0fc2";
    #     sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
    #   };
    # }
    # {
    #   name = "zsh-colored-man-pages";
    #   file = "colored-man-pages.plugin.zsh";
    #   src = fetchFromGitHub {
    #     owner = "ael-code";
    #     repo = "zsh-colored-man-pages";
    #     rev = "57bdda68e52a09075352b18fa3ca21abd31df4cb";
    #     sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
    #   };
    # }
    # {
    #   name = "oh-my-zsh_aws2-plugin";
    #   file = "aws2/aws2.plugin.zsh";
    #   src = fetchFromGitHub {
    #     owner = "drgr33n";
    #     repo = "oh-my-zsh_aws2-plugin";
    #     rev = "f5f5aaf32b59a7cb5a65e76284f13943e086e19b";
    #     sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
    #   };
    # }
      ];
  };
}
