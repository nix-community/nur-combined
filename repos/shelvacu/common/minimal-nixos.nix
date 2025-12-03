{
  config,
  pkgs,
  lib,
  vacuModuleType,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
in
lib.optionalAttrs (vacuModuleType == "nixos") {
  config = mkIf config.vacu.isMinimal {
    programs.git.lfs.enable = false;
    programs.git.package = pkgs.gitMinimal;

    nix.registry.nixpkgs.to = lib.mkForce {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      rev = inputs.nixpkgs.rev;
    };
    # mostly copied from nixos's /profiles/minimal.nix
    documentation.enable = mkDefault false;

    documentation.doc.enable = mkDefault false;

    documentation.info.enable = mkDefault false;

    documentation.man.enable = mkDefault false;

    documentation.nixos.enable = mkDefault false;

    # Perl is a default package.
    environment.defaultPackages = mkDefault [ ];

    environment.stub-ld.enable = false;

    # The lessopen package pulls in Perl.
    programs.less.lessopen = mkDefault null;

    programs.command-not-found.enable = mkDefault false;

    services.logrotate.enable = mkDefault false;

    services.udisks2.enable = mkDefault false;

    xdg.autostart.enable = mkDefault false;
    xdg.icons.enable = mkDefault false;
    xdg.mime.enable = mkDefault false;
    xdg.sounds.enable = mkDefault false;
  };
}
