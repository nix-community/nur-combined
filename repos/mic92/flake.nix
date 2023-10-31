{
  description = " My personal NUR repository";
  inputs.nixpkgs.url = "github:Mic92/nixpkgs/main";
  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        #"x86_64-darwin"
        #"aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      });
      checks = forAllSystems (system: self.packages.${system});
    };
}
