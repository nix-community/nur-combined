{ pkgs }:
let
	pname = "playit-agent";
	version = "1.0.5";
in
	pkgs.rustPlatform.buildRustPackage {
		src = pkgs.fetchFromGitHub {
			owner = "playit-cloud";
			repo = pname;
			rev = "v${version}";
			hash = "sha256-r0Rbdiv8vMXMwjsD/sRnrzT7BATheU7DJ1qgQWATAwM=";
		};

		inherit pname version;

		cargoHash = "sha256-Wf8eJTSTAxo56t/ImRXzn7wl1mo4y4D/TQ5JHGoPCrc=";

		meta = with pkgs.lib; {
			homepage = "https://github.com/playit-cloud/playit-agent";
			license = licenses.bsd2;
			description = "Make Your Game Server Public in Minutes";
		};
	}
