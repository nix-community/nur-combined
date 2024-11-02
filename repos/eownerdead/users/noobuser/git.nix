{ config, pkgs, ... }:
let
  email = config.accounts.email.accounts."eownerdead@disroot.org";
in
{
  imports = [ ./email.nix ];

  home.packages = with pkgs; [ stgit ];

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
    aliases = {
      c = "commit";
      co = "checkout";
      b = "branch";
      br = "branch";
      d = "diff";
      f = "fetch";
      l = "log";
      m = "merge";
      r = "rebase";
      s = "status";
    };
    extraConfig = {
      init.defaultBranch = "main";
      commit.verbose = true;
      core.quotepath = false;
      credential.helper = [ "cache" ];
    };
  };
}
