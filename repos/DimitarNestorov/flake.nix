{
	description = "Dimitar Nestorov's Nix packages";
	inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
	outputs = { self, nixpkgs }:
		let
			systems = [
				"aarch64-darwin"
				"x86_64-darwin"
			];
			forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
		in
		{
			legacyPackages = forAllSystems (system: import ./default.nix {
				pkgs = import nixpkgs { inherit system; };
			});
			packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});

			overlay = final: prev: {
				DimitarNestorov = import ./default.nix {
					pkgs = prev;
				};
			};
		};
}
