{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "blflash";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "spacemeowx2";
    repo = "blflash";
    rev = "v${version}";
    sha256 = "1r0xyb0v2nw5hnlpmvpbbc2yqyamg29q4q708hlimdb1cxz3p12w";
  };

  cargoSha256 = "03v6b8bq5vil4jg37z8vqw9qyyv37j3p8jr85hmacfr5f61zdz3j";

  meta = with lib; {
    description = "An bl602 serial flasher written in Rust";
    homepage = "https://github.com/spacemeowx2/blflash";
    license = with licenses; [ mit asl20 ];
    maintainers = with maintainers; [ _0x4A6F ];
  };
}
