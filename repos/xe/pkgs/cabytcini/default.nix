{ pkgs ? import <nixpkgs> { } }:

with pkgs;

rustPlatform.buildRustPackage rec {
  name = "cabytcini-${version}";
  version = "0.2.1";

  src = fetchgit {
    url = "https://tulpa.dev/cadey/cabytcini";
    rev = "3de2d10f905b9fd5781fc5dc374fbd1df982716c";
    sha256 = "1bkfqyphdk2z7zhwp75xma93hi9fkgqg97a6wps0hvkwl1ar7c5f";
  };

  buildInputs = [ pkg-config xorg.libX11 openssl ];

  legacyCargoFetcher = true;
  cargoSha256 = "1kwz2fz5n243j8zn7kw7r096h4hg4vkxcp0c2x5zksc71fkfpaa2";

  meta = with lib; {
    description = "lo mi cabytcini cankyuijde";
    homepage = "https://tulpa.dev/cadey/cabytcini";
    license = licenses.mit;
    maintainers = [ maintainers.xe ];
  };
}
