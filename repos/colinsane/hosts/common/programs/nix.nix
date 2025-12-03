{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.nix;
in
{
  sane.programs.nix = {
    packageUnwrapped = pkgs.lix;
    # packageUnwrapped = pkgs.nixVersions.latest; #< XXX(2025-03-17): sometimes `nixVersions.latest` fails to eval T_T
    # packageUnwrapped = pkgs.nix.overrideAttrs (_: {
    #   # ship debug info, used by gdb (/run/current-system/sw/lib/debug)
    #   separateDebugInfo = true;
    # });
    sandbox.method = null;  #< TODO: sandbox ?
    env.NIXPKGS_ALLOW_UNFREE = "1";  #< FUCK OFF YOU'RE SO ANNOYING
    persist.byStore.plaintext = [
      # ~/.cache/nix can become several GB; persisted to save RAM
      ".cache/nix"
    ];
  };

  # TODO: move the rest of the nix program config out of hosts/common/nix.nix, to here?
  nix.package = lib.mkIf cfg.enabled (
    cfg.package
  );
}
