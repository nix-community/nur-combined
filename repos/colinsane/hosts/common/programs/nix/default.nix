{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.nix;
in
{
  sane.programs.nix = {
    packageUnwrapped = pkgs.lix;
    # pin lix 2.95.0 because of its awesome `log-format` option, but not *strictly* required.
    # packageUnwrapped = lib.warnIf (lib.versionOlder "2.95.0" pkgs.lix.version) "stable lix >= 2.95.0: remove `latest.lix` override?" pkgs.lixPackageSets.latest.lix;
    # packageUnwrapped = pkgs.nixVersions.latest; #< XXX(2025-03-17): sometimes `nixVersions.latest` fails to eval T_T
    # packageUnwrapped = pkgs.nix.overrideAttrs (_: {
    #   # ship debug info, used by gdb (/run/current-system/sw/lib/debug)
    #   separateDebugInfo = true;
    # });
    sandbox.method = null;  #< TODO: sandbox ?
    env.NIXPKGS_ALLOW_UNFREE = "1";  #< FUCK OFF YOU'RE SO ANNOYING

    # XXX(2025-12-21): set `env.NIX_PATH` instead of `nix.nixPath` as the latter applies to the daemon as well;
    # only the former allows `NIX_PATH= nix-build ...` to actually do a build w/o overlays.
    #
    # allow `nix-shell` (and probably nix-index?) to locate our patched and custom packages.
    # this setting alone doesn't have effect; rather it influences `nix.settings.nix-path` (above), which has the actual effect.
    # env.NIX_PATH = lib.mkForce (lib.concatStringsSep ":" ((lib.optionals (config.sane.maxBuildCost >= 2) [
    #   "nixpkgs=${pkgs.path}"
    # ]) ++ [
    #   # note the import starts at repo root: this allows `./overlay/default.nix` to access the stuff at the root
    #   # "nixpkgs-overlays=${../../../..}/hosts/common/nix-path/overlay"
    #   # as long as my system itself doesn't rely on NIXPKGS at runtime, we can point the overlays to git
    #   # to avoid `switch`ing so much during development.
    #   # TODO: it would be nice to remove this someday!
    #   # it's an impurity that touches way more than i need and tends to cause hard-to-debug eval issues
    #   # when it goes wrong. should i port my `nix-shell` scripts to something more tailored to my uses
    #   # and then delete `nixpkgs-overlays`?
    #   "nixpkgs-overlays=/home/colin/dev/nixos/integrations/nixpkgs/nixpkgs-overlays.nix"
    # ]));

    persist.byStore.plaintext = [
      # ~/.cache/nix can become several GB; persisted to save RAM
      ".cache/nix"
    ];
  };

  # TODO: move the rest of the nix program config out of hosts/common/nix.nix, to here?
  nix.package = lib.mkIf cfg.enabled (
    cfg.package
  );

  # environment.sessionVariables = lib.mkIf cfg.enabled {
  #   # XXX(2025-12-21): nixpkgs forcibly assigns `NIX_PATH = config.nix.nixPath` if `config.nix.enable` is true.
  #   # that's by design: nix has a default NIX_PATH value unless it's explicitly set (even if set empty).
  #   NIX_PATH = lib.mkForce cfg.env.NIX_PATH;
  # };
}
