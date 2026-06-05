{ config, pkgs, ... }:
{
  # provides `nix-locate`, backed by the manually run `nix-index`
  sane.programs.nix-index = {
    packageUnwrapped = pkgs.nix-index.override {
      nix = config.sane.programs.nix.package;
    };

    sandbox.net = "clearnet";
    sandbox.extraPaths = [
      "/nix"
    ];

    persist.byStore.plaintext = [ ".cache/nix-index" ];
  };
}
