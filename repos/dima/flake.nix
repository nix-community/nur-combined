{
	description = "My personal NUR repository";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
	};

	outputs = { self, nixpkgs }:
		let
			forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
		in
		{
			legacyPackages = forAllSystems (system: import ./default.nix {
				pkgs = nixpkgs.legacyPackages.${system};
			});

			packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
		};
}
