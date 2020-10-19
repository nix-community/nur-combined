{
  outputs = { self, nixpkgs }: {
    overlay = final: prev: {
      nur = import ./default.nix {
        pkgs = prev;
      };
    };
  };
}
