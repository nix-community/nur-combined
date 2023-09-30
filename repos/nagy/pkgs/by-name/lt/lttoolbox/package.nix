{ stdenv
, lib
, fetchFromGitHub
, autoconf
, automake
, libtool
, libxml2
, libxslt
, pkg-config
, flex
, pcre
, pcre-cpp
, autoreconfHook
}:

stdenv.mkDerivation rec {
  pname = "lttoolbox";
  version = "3.5.4";

  src = fetchFromGitHub {
    owner = "apertium";
    repo = "lttoolbox";
    rev = "v${version}";
    sha256 = "sha256-FK5Stq+fzGCjL0Dq5Wg3vpNzVB9e56QPx/5dOKACjxk=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];

  buildInputs =
    [ autoconf automake libtool libxml2 libxslt flex pcre pcre-cpp ];

  meta = with lib; {
    description =
      "Finite state compiler, processor and helper tools used by apertium";
    homepage = "https://github.com/apertium/lttoolbox";

    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
