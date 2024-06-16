{ pkgs, config, lib, ... }:{
  programs.git = {
    enable = true;
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      user = {
        email = "106440141+harukafractus@users.noreply.github.com";
        name = "harukafractus";
        signingkey = "~/.ssh/id_rsa.pub";
      };
      gpg = {
        format = "ssh";
      };
      commit = {
        gpgSign = true;
      };
    };
  };
}