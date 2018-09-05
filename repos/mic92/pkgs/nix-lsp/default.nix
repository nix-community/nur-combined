{ stdenv, rustNightlyPlatform, fetchFromGitLab }: 

rustNightlyPlatform.buildRustPackage rec {
  name = "nix-lsp-${version}";
  version = "2018-08-29";

	cargoSha256 = "0n4a684ybh109pdi5i40zqca532k3ir5scykp4hl89qjbvaf1frh";

	src = fetchFromGitLab {
		sha256 = "0fdmlyjz1j3jvq256ysc7ap2f2szgqb6da9l0fd3z5cv5y8whd0s";
		rev = "346b3fd67843a5445a54994dac4043d002a38e2e";
		repo = "nix-lsp";
		owner = "jD91mZM2";
	};
}
