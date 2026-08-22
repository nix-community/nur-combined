{
  perSystem = { pkgs, ... }: {
    devShells.default =
      with pkgs;
      mkShell {
        name = "ifd3f-nur-devshell";
        buildInputs = [ zon2nix ];
      };
  };
}
