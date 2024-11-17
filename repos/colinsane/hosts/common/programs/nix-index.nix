{ ... }:
{
  # provides `nix-locate`, backed by the manually run `nix-index`
  sane.programs.nix-index = {
    sandbox.net = "clearnet";
    sandbox.extraPaths = [
      "/nix"
    ];

    persist.byStore.plaintext = [ ".cache/nix-index" ];
  };
}
