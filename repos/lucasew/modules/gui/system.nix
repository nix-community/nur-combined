let
  cfg = import ../../globalConfig.nix;
  selectedDe = cfg.selectedDesktopEnvironment;
in import (./engine + "/${selectedDe}.nix")
