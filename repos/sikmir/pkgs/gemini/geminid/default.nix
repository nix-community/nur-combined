{ lib, stdenv, fetchFromGitHub, libconfig, file, openssl, flex }:

stdenv.mkDerivation rec {
  pname = "geminid";
  version = "2021-04-11";

  src = fetchFromGitHub {
    owner = "jovoro";
    repo = "geminid";
    rev = "bf6148baf91847e8dc011c3a101bee547142f4b5";
    hash = "sha256-yiD3GMrYi9KhKgCWAs+tdenP/0Q1E16FdhatdbTkYK4=";
  };

  nativeBuildInputs = [ flex ];

  buildInputs = [ libconfig file openssl.dev ];

  makeFlags = [ "geminid" "CC:=$(CC)" "LEX=flex" ];

  installPhase = "install -Dm755 geminid -t $out/bin";

  meta = with lib; {
    description = "Gemini Server in C";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
