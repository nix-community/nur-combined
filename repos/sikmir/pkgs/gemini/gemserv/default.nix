{ lib, stdenv, rustPlatform, fetchFromSourcehut, pkg-config, openssl, Security }:

rustPlatform.buildRustPackage rec {
  pname = "gemserv";
  version = "0.6.3";

  src = fetchFromSourcehut {
    owner = "~int80h";
    repo = "gemserv";
    rev = "v${version}";
    hash = "sha256-JA+mxljfYPWP5RcsknP+5gBSczKNSa5/BuDiY7mS3TY=";
  };

  cargoHash = "sha256-anPHujCUkoIybg8wltDkf3jpHEsPS6GTNJiUPLXAI9k=";

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
