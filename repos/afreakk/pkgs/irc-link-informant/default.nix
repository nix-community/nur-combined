{ pkgs }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "IRC-Link-Informant";
  version = "efc351261b130aa2163b6a48f12f4071705de556";

  src = pkgs.fetchFromGitHub {
    owner = "afreakk";
    repo = pname;
    rev = version;
    sha256 = "1irws6ca8g069q4l4vwgva9n3572xdjql6l32wnhqyngjfv6pgas";
  };

  cargoSha256 = "12sa8jjza22f5f3rb12xbfixp2i2l3v3xyj5l3q0sf77ipdr2j88";
  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ pkgs.openssl_1_1 ];
}
