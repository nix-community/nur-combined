{ lib, stdenv, fetchFromGitHub, SDL2, glew, lua }:

stdenv.mkDerivation rec {
  pname = "cadzinho";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "zecruel";
    repo = "CadZinho";
    rev = version;
    hash = "sha256-38FZsCyyUuQZS7fqZBzWWvNAkGTg36uEehtnm/RJH64=";
  };

  buildInputs = [ SDL2 glew lua ];

  makeFlags = [ "CC:=$(CC)" ];

  NIX_CFLAGS_COMPILE = "-Wno-format-security";

  installPhase = ''
    install -Dm755 cadzinho -t $out/bin
  '';

  meta = with lib; {
    description = "Minimalist computer aided design (CAD) software";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
