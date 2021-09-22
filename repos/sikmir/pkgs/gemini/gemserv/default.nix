{ lib, stdenv, rustPlatform, fetchFromSourcehut, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "gemserv";
  version = "0.4.5";

  src = fetchFromSourcehut {
    owner = "~int80h";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-9O4kzNpc4alnjJ3ioCv1kKfNDxIu5IA8PX0EUb6S2RY=";
  };

  cargoHash = "sha256-if9rWZffXVL9nijtdaisgaabyKkEpJkDeYKv2L4/4co=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  postInstall = ''
    install -Dm644 config.toml -t $out/share/gemserv
  '';

  meta = with lib; {
    description = "A gemini server written in rust";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
