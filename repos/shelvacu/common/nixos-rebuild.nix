{
  pkgs,
  config,
  lib,
  vacuModuleType,
  ...
}:
let
  nixos-rebuild = pkgs.nixos-rebuild.override { nix = config.nix.package; };
in
lib.optionalAttrs (vacuModuleType == "nixos") {
  system.build.nixos-rebuild = lib.mkForce (
    pkgs.runCommandLocal "nixos-rebuild-wrapped"
      {
        nativeBuildInputs = [ pkgs.makeShellWrapper ];
        meta.mainProgram = "nixos-rebuild";
        meta.priority = (pkgs.nixos-rebuild.meta.priority or lib.meta.defaultPriority) + 10;
      }
      ''
        mkdir -p "$out"/bin
        makeShellWrapper ${lib.getExe nixos-rebuild} "$out"/bin/nixos-rebuild --add-flags "--use-remote-sudo"
      ''
  );
}
