{pkgs, ...}:
let
  globalConfig = import <dotfiles/globalConfig.nix>;
  nurRepo = globalConfig.repos.nur;
in import nurRepo {
  inherit pkgs;
}
