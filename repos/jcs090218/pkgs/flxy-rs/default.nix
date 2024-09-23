{
	rustPlatform,
	fetchFromGitHub,
	lib,
}:

rustPlatform.buildRustPackage rec {
	pname = "flxy-rs";
	version = "0.1.19";

	src = fetchFromGitHub {
		owner = "jcs-legacy";
		repo = pname;
		rev = "${version}";
		sha256 = "";
	};

	cargoHash = "";
	doCheck = false;

	meta = {
		description = "Fast, character-based search library in Rust";
		homepage = "https://github.com/jcs-legacy/flxy-rs";
		license = lib.licenses.mit;
	};
}
