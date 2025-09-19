{
  description = "Jux's NUR";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.jux-is-a-nix-maintainer-apparently.url = "git+https://codeberg.org/JuxGD/jux-is-a-nix-maintainer-apparently?ref=main";

  outputs = { self, nixpkgs, jux-is-a-nix-maintainer-apparently }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
        inputs = inputs;
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
    };
}
