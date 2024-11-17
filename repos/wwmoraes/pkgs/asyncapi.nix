{ buildNpmPackage, fetchFromGitHub, importNpmLock, lib }:

buildNpmPackage rec {
	pname = "asyncapi";
	version = "2.8.0";

	src = fetchFromGitHub {
		owner = "asyncapi";
		repo = "cli";
		rev = "v${version}";
		hash = "sha256-gbA2/O5Q18uHyCZX99cPfpGMTYqffyR6sisEmeFLy6A=";
	};

	# npmDeps = importNpmLock {
	# 	npmRoot = src;
	# };
	# npmConfigHook = importNpmLock.npmConfigHook;

	npmDepsHash = "sha256-tZgnKJW49/y1+hSBjwFXCJrplBkkL87Bux7LqOoNSAg=";
	npmPackFlags = [ "--ignore-scripts" ];

	## we need to override the original script as they fetch
	## examples from another repo.
	## TODO include examples like the upstream
	buildPhase = ''
		runHook preBuild

		export PATH=$PWD/node_modules/.bin:$PATH

		mkdir -p assets/examples
		echo '[]' > assets/examples/examples.json

		rimraf lib
		tsc
		oclif manifest

		runHook postBuild
	'';

	meta = with lib; {
		description = "CLI to work with your AsyncAPI files";
		homepage = "https://github.com/asyncapi/cli";
		license = licenses.asl20;
		maintainers = with maintainers; [ wwmoraes ];
	};
}
