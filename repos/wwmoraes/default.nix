{
	system ? builtins.currentSystem,
	pkgs ? import <nixpkgs> { inherit system; }
}: let
	callPackage = pkgs.lib.callPackageWith (pkgs // self);
	self = {
		modules = import ./modules;
		ejson = callPackage ./pkgs/ejson.nix { };
		go-commitlint = callPackage ./pkgs/go-commitlint.nix { };
		gopium = callPackage ./pkgs/gopium.nix { };
		goutline = callPackage ./pkgs/goutline.nix { };
		kroki = callPackage ./pkgs/kroki.nix { };
		kroki-cli = callPackage ./pkgs/kroki-cli.nix { };
		pkgsite = callPackage ./pkgs/pkgsite.nix { };
		structurizr-cli = callPackage ./pkgs/structurizr-cli.nix { };
		structurizr-site-generatr = callPackage ./pkgs/structurizr-site-generatr.nix { };
		yamlfixer = callPackage ./pkgs/yamlfixer.nix { };
	};
in self
