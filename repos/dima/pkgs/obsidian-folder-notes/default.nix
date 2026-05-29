{ pkgs }:
let
	revision = "1.8.18";
in
	pkgs.buildNpmPackage {
		pname = "obsidian-folder-notes";
		version = revision;

		src = pkgs.fetchFromGitHub {
			owner = "LostPaul";
			repo = "obsidian-folder-notes";
			rev = revision;
			hash = "sha256-dIwjeabJ4/EhAqgD+FhgGHTzj/uG1VDgkyX8FAoONTg=";

			fetchSubmodules = true;
		};

		npmDepsHash = "sha256-XH2oElA4DyPqyr8zyVpomTGHmSs9Hz0e5EhyvZc552o=";
		npmFlags = [ "--legacy-peer-deps" ];

		ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

		buildPhase = ''
			npm run fn-build
		'';

		installPhase = ''
			mkdir -p $out
			cp main.js styles.css manifest.json $out
		'';

		meta = with pkgs.lib; {
			homepage = "https://github.com/LostPaul";
			license = licenses.agpl3Only;
			description = "Create notes within folders that can be accessed without collapsing the folder, similar to the functionality offered in Notion";
		};
	}
