{ pkgs ? import <nixpkgs> { } }:

with pkgs;

rustPlatform.buildRustPackage rec {
  name = "cabytcini-${version}";
  version = "0.2.2";

  src = fetchgit {
    url = "https://tulpa.dev/cadey/cabytcini";
    rev = "c78fb3dcb50120d34637dd66d08944d1dffa41e4";
    sha256 = "1b2m7y9al62ihpyjg1jjplwbkgw74189rkvp0llr5pd9rwg9vpfj";
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
