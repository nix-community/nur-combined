{
  lib,
  config,
  pkgs,
  ...
}:
let
  # email = config.accounts.email.accounts."eownerdead@disroot.org";
in
{
  imports = [
    ./cli.nix
    ./gpg.nix
  ];

  options.eownerdead.git.enable = lib.mkEnableOption "Enable git";

  config = lib.mkIf config.eownerdead.git.enable {
    programs = {
      git = {
        enable = true;
        package = pkgs.gitFull;
        settings = {
          user = {
            email = "eownerdead@disroot.org";
            name = "EOWNERDEAD";
          };
          init.defaultBranch = "main";
          commit.verbose = true;
          core.quotepath = false;
          credential.helper = [ "cache" ];
          rerere.enabled = true;
          alias = {
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
        };
        signing = {
          key = "009E56305CA54D63";
          # inherit (email.gpg) key;
          signByDefault = true;
        };
      };
      delta = {
        enable = true;
        enableGitIntegration = true;
      };
    };
  };
}
