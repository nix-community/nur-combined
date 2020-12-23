{
  description = "kampka's NUR repository";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = { self, nixpkgs }: {
    nixosModules = import ./modules;
    devShell."x86_64-linux" = let pkgs = import nixpkgs { system = "x86_64-linux"; }; in
      pkgs.mkShell {
        buildInputs = [ pkgs.nixpkgs-fmt ];
      };
  };

}
