{ lib, stdenv, rustPlatform, fetchFromSourcehut, pkg-config, openssl, Security }:

rustPlatform.buildRustPackage rec {
  pname = "gemserv";
  version = "0.6.6";

  src = fetchFromSourcehut {
    owner = "~int80h";
    repo = "gemserv";
    rev = "v${version}";
    hash = "sha256-jFh7OksYGXGWwLb4HtAuDQ7OsWxedqeLARPI20RyAgQ=";
  };

  cargoHash = "sha256-mGcZiSOwgRki3OfbbcNL/1avj6T5XD7ebjg9THIzUIQ=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ] ++ lib.optional stdenv.isDarwin Security;

  postInstall = ''
    install -Dm644 config.toml -t $out/share/gemserv
  '';

  meta = with lib; {
    description = "A gemini server written in rust";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
