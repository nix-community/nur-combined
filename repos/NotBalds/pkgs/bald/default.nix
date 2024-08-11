{ stdenv, fetchFromGitHub, gnumake, gcc }:
stdenv.mkDerivation {
	pname = "bald";
	version = "v1.0.0";
	src = fetchFromGitHub {
		owner = "NotBalds";
		repo = "bald";
		rev = "7a31e3c6b25788dc9443f5a726224c15ffa9df16";
		hash = "sha256-eEohxzltnD7Y2a6SsxpEXgIBcSNZ3tIP4vQrC5o/Zqo=";
	};
	nativeBuildInputs = [ gnumake gcc ];
	buildPhase = "make build";
	installPhase = "mkdir -p $out/bin && cp out $out/bin/bald";
	meta = {
		description = "Bald is deadly simple c++ build system";
		homepage = "https://github.com/NotBalds/bald";
		mainProgram = "bald";
	};
}
