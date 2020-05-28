{ pkgs ? import <nixpkgs> { } }:
with pkgs;

rustPlatform.buildRustPackage rec {
  pname = "quickserv";
  version = "0.1.0";

  src = fetchgit {
    url = "https://tulpa.dev/Xe/quickserv";
    rev = "v${version}";
    sha256 = "0v3b8l4cbqx8vxi4dg44rvg61bc5rpmjxyzx015687n72vz9s7rn";
  };

  legacyCargoFetcher = true;
  cargoSha256 = "07crv9wx0zg0fjga6alx3pks7cnkla9p6y9jy8wq13y3q7yrm8n9";

  meta = with lib; {
    description = "A quick HTTP server for when you've given up on life";
    homepage = "https://tulpa.dev/Xe/quickserv";
    license = licenses.mit;
    maintainers = [ maintainers.xe ];
  };
}
