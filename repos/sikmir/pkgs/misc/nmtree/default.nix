{ lib, stdenv, fetchFromGitHub, autoreconfHook, libnbcompat }:

stdenv.mkDerivation rec {
  pname = "nmtree";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "archiecobbs";
    repo = "nmtree";
    rev = version;
    hash = "sha256-0NlrWnSi0Eyz9WlTX1OpU3dHpgZMOF0rtf9cY5mLDkc=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [ libnbcompat ];

  NIX_CFLAGS_COMPILE = "-Wno-format-security";

  meta = with lib; {
    description = "NetBSD's mtree(8) utility";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = true;
  };
}
