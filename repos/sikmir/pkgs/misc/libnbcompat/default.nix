{ lib, stdenv, fetchFromGitHub, autoreconfHook }:

stdenv.mkDerivation rec {
  pname = "libnbcompat";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "archiecobbs";
    repo = "libnbcompat";
    rev = version;
    hash = "sha256-DyBLEp5dNYSQgTzdQkGfLdCtX618EbnVy5FmL75BMdU=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  meta = with lib; {
    description = "Portable NetBSD-compatibility library";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
