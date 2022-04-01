{ pkgs, lib, rustPlatform, fetchFromGitHub, openssl, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "bindle";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "deislabs";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-V/BakTjakllM+wBC67T4xmHVZzFuDngi4bNmsJo0340=";
  };

  cargoSha256 = "sha256-o6I6usKTD9ZPKQKxdGgWYOs7vDzx9q+ERKkBlSZtj4s=";

  buildFeatures = [ "cli" ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  # tests fail
  doCheck = false;

  meta = with lib; {
    description = "Object Storage for Collections";
    homepage = "https://github.com/deislabs/bindle";
    license = licenses.asl20;
  };
}
