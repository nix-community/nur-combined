{ stdenv , lib , fetchFromGitHub , rustPlatform, openssl, sqlite, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname = "isostatic";
  version = "v0.1.1";

  src = fetchFromGitHub {
    owner = "nerdypepper";
    repo = pname;
    rev = version;
    sha256 = "0a2v42kpsnk81hxdval0swifd068wqi8cwa21q1xp8bk5plwgybq";
  };

  cargoSha256 = "1i9xv5762ikrin9jjcmn4yhwp8jdmprcws6pax9pa2a7i3jnvh4p";

  buildInputs = [ sqlite openssl ];

  meta = with lib; {
    description = "minimal url shortner service";
    homepage = "https://isosta.tk";
    license = licenses.mit;
  };
}

