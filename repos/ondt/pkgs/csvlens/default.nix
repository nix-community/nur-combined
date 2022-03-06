{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
	pname = "csvlens";
	version = "0.1.1";

	src = fetchFromGitHub {
		owner = "YS-L";
		repo = pname;
		rev = "59adc5df43e0732c92c5f27c471536094b7b8edb";
		sha256 = "sha256-O5mxk8ZesUOHdu+4/loL2WTWOjeXN7PiGeGjHbcoNkM=";
	};

	cargoSha256 = "sha256-48K0lwBE6ZIOpXJgbt5gm4FyzxOwzzKSEcRS/vjNjBE=";

	meta = with lib; {
		description = "Command line csv viewer";
		homepage = "https://github.com/YS-L/csvlens";
		license = licenses.mit;
	};
}
