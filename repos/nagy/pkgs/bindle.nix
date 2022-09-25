{ pkgs, lib, rustPlatform, fetchFromGitHub, openssl, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "bindle";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "deislabs";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Mc3LaEOWx8cN7g0r8CtWkGZ746gAXTaFmAZhEIkbWgM=";
  };

  cargoSha256 = "sha256-brsemnw/9YEsA2FEIdYGmQMdlIoT1ZEMjvOpF44gcRE=";

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
