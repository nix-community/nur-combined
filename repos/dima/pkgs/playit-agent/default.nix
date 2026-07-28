{ pkgs }:
let
	pname = "playit-agent";
	version = "1.0.10";
in
	pkgs.rustPlatform.buildRustPackage {
		src = pkgs.fetchFromGitHub {
			owner = "playit-cloud";
			repo = pname;
			tag = "v${version}";
			hash = "sha256-aofn28wCivn7ih7DXnyaBSuj3YW63EiyDx/GY1W42XI=";
		};

		inherit pname version;

		cargoHash = "sha256-pdCzqg0SuzC3qwOQ2fOgi8Nuhgy/R1dTLcS/qA7Crq0=";

		meta = with pkgs.lib; {
			homepage = "https://github.com/playit-cloud/playit-agent";
			license = licenses.bsd2;
			description = "Make Your Game Server Public in Minutes";
		};
	}
