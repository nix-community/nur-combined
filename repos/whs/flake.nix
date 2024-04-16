{
	outputs = { self, nixpkgs, flake-utils }: {
		nixosModules = import ./modules.nix;
	} // flake-utils.lib.eachDefaultSystem (system: 
		let
			pkgs = import nixpkgs { inherit system; };
			stdenv = pkgs.stdenv;
			lib = pkgs.lib;
		in {
			packages = pkgs.callPackage ./default.nix {};
		}
	);
}
