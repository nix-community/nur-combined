{
  inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";
    mozilla-addons-to-nix.url = "sourcehut:~rycee/mozilla-addons-to-nix";

    cache-nix-action = {
      url = "github:nix-community/cache-nix-action";
      flake = false;
    };
  };

  outputs = _: { };
}
