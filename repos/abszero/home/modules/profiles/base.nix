{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) const;
in

{
  # FIXME: Still broken, needs --impure to build
  nixpkgs.config.allowUnfreePredicate = const true;

  home = {
    stateVersion = "24.05";
    # Print store diff using nvd
    activation.diff = config.lib.dag.entryBefore [ "writeBoundary" ] ''
      ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
    '';
  };

  xdg.enable = true;

  programs.home-manager.enable = true;
}
