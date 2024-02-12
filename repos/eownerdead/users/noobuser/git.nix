{ config, pkgs, ... }:
let
  gitAlias = pkgs.fetchurl {
    url =
      "https://raw.githubusercontent.com/GitAlias/gitalias/ed036c1fd16c8e690329c594bc028f58c6e3b349/gitalias.txt";
    hash = "sha256-tcZNjDClFz6Auj+cdWVQxXL5zg+fvIbaz02C/acbBs4=";
  };
  email = config.accounts.email.accounts."eownerdead@disroot.org";
in {
  imports = [ ./email.nix ];

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    delta.enable = true;
    userEmail = email.address;
    userName = email.realName;
    signing = {
      inherit (email.gpg) key;
      signByDefault = true;
    };
    extraConfig = {
      include.path = "${gitAlias}";
      init.defaultBranch = "main";
      commit.verbose = true;
      core.quotepath = false;
      credential.helper = [ "cache" ];
    };
  };
}

