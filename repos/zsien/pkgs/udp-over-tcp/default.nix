{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "udp-over-tcp";
  version = "unstable-2022-03-08";

  src = fetchFromGitHub {
    owner = "mullvad";
    repo = pname;
    rev = "459056c551e03ec5adf360c929a59dc5d9fa6f52";
    sha256 = "sha256-bjKissHpRImilKE8NmoHvN5ygZxg/CUKpGmNKnEJlfo=";
  };

  cargoSha256 = "sha256-yKuaz8yNJzoY3VVp5K27pkxxXCyZ07Mxw3skOYwQ2HE=";

  meta = with lib; {
    description = "A library (and binaries) for tunneling UDP datagrams over a TCP stream.";
    homepage = "https://github.com/mullvad/udp-over-tcp";
    license = with licenses; [ mit asl20 ];
  };
}
