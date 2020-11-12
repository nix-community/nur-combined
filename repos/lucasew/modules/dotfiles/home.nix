{ pkgs, ...}:
let
  globalConfig = import <dotfiles/globalConfig.nix>;
  generator = import <dotfiles/lib/generateDotfilerc.nix>;
in
{
  home.file.".dotfilerc".text = ''
    #!/usr/bin/env bash
    ${generator globalConfig}
  '';
}
