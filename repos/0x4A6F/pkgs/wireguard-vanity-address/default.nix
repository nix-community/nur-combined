{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "wireguard-vanity-address";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "warner";
    repo = "wireguard-vanity-address";
    rev = "v${version}";
    sha256 = "1ni8isfg4c0szh2djhqlhynn1mj9qq2hpvlgx57hh7rxhiadqg2a";
  };

  cargoSha256 = "1dchbqgl8vy26c733f641pnshpbmnx8915pnppsa3cick6i35ffi";

  meta = with lib; {
    description = "Generate Wireguard keypairs with a given prefix string";
    homepage = "https://github.com/warner/wireguard-vanity-address";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ _0x4A6F ];
  };
}
