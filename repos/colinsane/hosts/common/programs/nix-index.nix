{ config, lib, ... }:
{
  # provides `nix-locate`, backed by the manually run `nix-index`
  sane.programs.nix-index = {
    persist.byStore.plaintext = [ ".cache/nix-index" ];
  };
}
