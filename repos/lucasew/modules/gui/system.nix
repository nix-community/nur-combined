let
  globalConfig = import <dotfiles/globalConfig.nix>;
in import (./engine + "/${globalConfig.selectedDesktopEnvironment}.nix")
