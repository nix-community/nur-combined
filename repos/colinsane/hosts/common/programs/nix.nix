{ ... }:
{
  sane.programs.nix = {
    # packageUnwrapped = pkgs.nixVersions.latest;  #< XXX(2025-03-17): sometimes `nixVersions.latest` fails to eval T_T
    sandbox.method = null;  #< TODO: sandbox ?
    env.NIXPKGS_ALLOW_UNFREE = "1";  #< FUCK OFF YOU'RE SO ANNOYING
    persist.byStore.plaintext = [
      # ~/.cache/nix can become several GB; persisted to save RAM
      ".cache/nix"
    ];
  };
}
