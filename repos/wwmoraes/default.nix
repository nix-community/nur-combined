{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
}: let
	nixpkgs = pkgs.lib.recursiveUpdate pkgs {
		lib.maintainers.wwmoraes = {
			email = "nixpkgs@artero.dev";
			github = "wwmoraes";
			githubId = 682095;
			keys = [ { fingerprint = "32B4 330B 1B66 828E 4A96  9EEB EED9 9464 5D7C 9BDE"; } ];
			matrix = "@wwmoraes:hachyderm.io";
			name = "William Artero";
		};
	};
	callPackage = nixpkgs.lib.callPackageWith (nixpkgs // self);
	self = {
		modules = import ./modules;
		nix-darwin = {
			modules = import ./nix-darwin/modules;
		};

		asyncapi = callPackage ./pkgs/asyncapi.nix { };
		ejson = callPackage ./pkgs/ejson.nix { };
		go-commitlint = callPackage ./pkgs/go-commitlint.nix { };
		gopium = callPackage ./pkgs/gopium.nix { };
		goutline = callPackage ./pkgs/goutline { };
		kroki = callPackage ./pkgs/kroki.nix { };
		kroki-cli = callPackage ./pkgs/kroki-cli.nix { };
		pkgsite = callPackage ./pkgs/pkgsite.nix { };
		structurizr-cli = callPackage ./pkgs/structurizr-cli.nix { };
		structurizr-site-generatr = callPackage ./pkgs/structurizr-site-generatr.nix { };
		yamlfixer = callPackage ./pkgs/yamlfixer.nix { };
	};
in self
