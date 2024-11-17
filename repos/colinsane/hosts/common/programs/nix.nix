{ pkgs, ... }:
{
  sane.programs.nix = {
    packageUnwrapped = pkgs.nixVersions.latest;
    sandbox.method = null;  #< TODO: sandbox ?
    env.NIXPKGS_ALLOW_UNFREE = "1";  #< FUCK OFF YOU'RE SO ANNOYING
    persist.byStore.plaintext = [
      # ~/.cache/nix can become several GB; persisted to save RAM
      ".cache/nix"
    ];
  };
}
