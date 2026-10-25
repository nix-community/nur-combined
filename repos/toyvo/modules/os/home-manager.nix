{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.nixcfg.home-manager;
in
{
  options.nixcfg.home-manager.enable = lib.mkEnableOption "home-manager integration";

  config = lib.mkIf cfg.enable {
    home-manager = {
      backupFileExtension = "${
        inputs.self.shortRev or inputs.self.dirtyShortRev or inputs.self.lastModifiedDate
      }.old";
      useUserPackages = true;
      sharedModules = [
        {
          nix.package = lib.mkForce config.nix.package;
          home.sessionVariables.NIXPKGS_ALLOW_UNFREE = 1;
        }
      ];
    };
  };
}
