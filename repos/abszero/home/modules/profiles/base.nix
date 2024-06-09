{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home = {
    stateVersion = "24.11";
    # Print store diff using nvd
    activation.diff = config.lib.dag.entryBefore [ "writeBoundary" ] ''
      if [[ -v oldGenPath ]]; then
        ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
      fi
    '';
  };

  xdg.enable = true;

  programs.home-manager.enable = true;
}
