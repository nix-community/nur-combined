{
  inputs.nixpkgs.url = "nixpkgs";
  inputs.iago-nix.url = "path:..";

  outputs = { self, nixpkgs, iago-nix }:
  let
    config = { allowUnfree = true; };
    nixpkgs-ov = system: import nixpkgs ({ inherit system; overlays = [ iago-nix.overlay ]; config = config; });
    nixpkgs-ins = nixpkgs-ov "x86_64-linux";
  in
  {
    legacyPackages."x86_64-linux" = nixpkgs-ins;
    devShell."x86_64-linux" = nixpkgs-ins.mkShell {
      nativeBuildInputs = with nixpkgs-ins; [ zig ];
    };
  };
}
