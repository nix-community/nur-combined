{ stdenv, rustPlatform, fetchFromGitHub
, openssl, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "dog";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ogham";
    repo = "dog";
    rev = "v${version}";
    sha256 = "088ib0sncv0vrvnqfvxf5zc79v7pnxd2cmgp4378r6pmgax9z9zy";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  cargoSha256 = "0q3jy8gykd7fhh4gdgfcbf30ksp78lq34pms6904c70skm6jnqck";

  meta = with stdenv.lib; {
    description = "Command-line DNS client";
    homepage = "https://dns.lookup.dog";
    license = licenses.eupl12;
  };
}
