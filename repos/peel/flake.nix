{
  description = "Peel's nur flake";

  outputs = { self }: {
    overlay = final: prev: {
      nur = import ./default.nix {
        nurpkgs = prev;
        pkgs = prev;
      };
    };
  };
}
