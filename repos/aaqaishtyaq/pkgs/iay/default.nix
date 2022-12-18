{
  stdenv, fetchFromGitHub, rustPlatform, openssl, pkg-config, pkgs 
}:

rustPlatform.buildRustPackage rec {
  pname = "iay";
  version = "0.4.0";

  buildInputs = [ openssl pkg-config ];

  src = fetchFromGitHub (builtins.fromJSON (builtins.readFile ./source.json));

  cargoSha256 = "sha256-SMqiwM6LrXXjV4Mb2BY9WbeKKPkxiYxPyZ4aepVIAqU=";

  meta = with pkgs.lib; {
    description =
      "iay! The minimalistic, blazing-fast, and extendable prompt for bash and zsh.";
    homepage = "https://github.com/aaqaishtyaq/iay";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
