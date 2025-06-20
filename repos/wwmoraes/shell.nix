let
	pkgs = import (fetchTarball {
		url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/24.05.tar.gz";
		sha256 = "1lr1h35prqkd1mkmzriwlpvxcb34kmhc9dnr48gkm8hh089hifmx";
		}) {
		config = {
			packageOverrides = pkgs: import ./default.nix { inherit pkgs; };
		};
	};
	# unstable = import (fetchTarball {
	#		 name = "nixos-unstable-a14c5d651cee9ed70f9cd9e83f323f1e531002db";
	#		 url = "https://github.com/NixOS/nixpkgs/archive/a14c5d651cee9ed70f9cd9e83f323f1e531002db.tar.gz";
	#		 sha256 = "1b2dwbqm5vdr7rmxbj5ngrxm7sj5r725rqy60vnlirbbwks6aahb";
	# }) {};
	inherit (pkgs) mkShell;
in mkShell {
	packages = [
		pkgs.cachix
		pkgs.eclint
		pkgs.editorconfig-checker
		pkgs.git
		pkgs.go-commitlint
		pkgs.go-task
		pkgs.lefthook
		pkgs.markdownlint-cli
		pkgs.nil
		pkgs.typos
		pkgs.yamlfixer
	] ++ pkgs.lib.optionals (builtins.getEnv "CI" != "") [ # CI-only
	] ++ pkgs.lib.optionals (builtins.getEnv "CI" == "") [ # local-only
		pkgs.yq-go
	];
}
