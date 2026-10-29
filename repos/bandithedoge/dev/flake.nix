{
  inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";

    cache-nix-action = {
      url = "github:nix-community/cache-nix-action";
      flake = false;
    };
  };

  outputs = _: { };
}
