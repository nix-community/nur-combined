{ buildGoModule
, fetchFromGitHub
, lib
}:

buildGoModule rec {
  pname = "ffuf";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "ffuf";
    repo = "ffuf";
    rev = "v${version}";
    sha256 = "01hv8r7vca1nm1rcgbw0g9jsqhc1j0i4n8cp14hi1s898bgypkq3";
  };

  vendorSha256 = "0sjjj9z1dhilhpc8pq4154czrb79z9cm044jvn75kxcjv6v5l2m5";
  modSha256 = vendorSha256;

  doCheck = false;

  meta = with lib; {
    description = "A fast web fuzzer written in Go";
    homepage = "https://github.com/ffuf/ffuf";
    license = licenses.mit;
    maintainers = with maintainers; [ htr ];
  };
}
