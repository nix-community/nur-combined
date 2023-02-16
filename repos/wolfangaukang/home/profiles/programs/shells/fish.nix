{ pkgs, ... }:

let 
  commonSettings = import ./common.nix;

in {
  programs.fish = {
    enable = true;
    plugins = 
      let
        inherit (pkgs) fetchFromGitHub;
      
      in [
        {
          name = "aws";
          src = pkgs.fetchFromGitHub {
            owner = "oh-my-fish";
            repo = "plugin-aws";
            rev = "a4cfb06627b20c9ffdc65620eb29abcedcc16340";
            sha256 = "sha256-NuWVCLgsO+pMbN3trQ8vnCRock05lroT1JCQUmYUIHI=";
            #fetchSubmodules = true;
          };
        }
        {
          name = "vcs";
          src = pkgs.fetchFromGitHub {
            owner = "oh-my-fish";
            repo = "plugin-vcs";
            rev = "535a98c71f37284c47c8750fa825dde650c592fb";
            sha256 = "sha256-NuWVCLgsO+pMbN3trQ8vnCRock05lroT1JCQUmYUIHI=";
            #fetchSubmodules = true;
          };
        }
      ];
    shellAliases = commonSettings.shellAliases;
  };
  home.sessionVariables = commonSettings.sessionVariables;
}
