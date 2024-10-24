{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
	pname = "ejson";
	version = "1.3.3";

	src = fetchFromGitHub {
		owner = "Shopify";
		repo = "ejson";
		rev = "v${version}";
		sha256 = "sha256-M2Gk+/l1tNlIAe1/fR1WLEOey+tjCUmMAujc76gmeZA=";
	};

	vendorHash = "sha256-9+x7HrbXRoS/7ZADWwhsbynQLr3SyCbcsp9QnSubov0=";

	ldflags = [ "-s" "-w" ];

	meta = with lib; {
		description = "Small library to manage encrypted secrets using asymmetric encryption";
		mainProgram = "ejson";
		license = licenses.mit;
		homepage = "https://github.com/Shopify/ejson";
		maintainers = with maintainers; [ manveru wwmoraes ];
	};
}
