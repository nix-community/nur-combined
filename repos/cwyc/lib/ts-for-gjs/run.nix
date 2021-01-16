let
	pkgs = import <nixpkgs> {};
in
	pkgs.callPackage (import ./default.nix) {} {
		name = "my-bundle";
		sources = with pkgs; [
			gtk3.dev
		];
		names = [
			"Gtk-3.0"
		];
		ignore = [];
		prettify = false;
	}