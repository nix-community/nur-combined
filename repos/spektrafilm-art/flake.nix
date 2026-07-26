{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  # darktable-spektrafilm builds the Arecsu spektrafilm-draft branch (darktable
  # 5.8.0) as an overrideAttrs on nixpkgs' darktable. No release channel ships
  # 5.8.0 yet, so we base it on nixpkgs-unstable (darktable 5.6.0) for the
  # closest dependency / cmake match, kept separate from the pinned `nixpkgs`
  # above so the Python spektrafilm packages stay on the stable 25.05 base.
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs, nixpkgs-unstable }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
        pkgsDarktable = import nixpkgs-unstable { inherit system; };
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
      nixosModules = import ./nixos-modules;
      # homeModules = import ./home-modules;
      # darwinModules = import ./darwin-modules;
      # flakeModules = import ./flake-modules;
    };
}
