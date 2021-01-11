{ stdenv, lib, fetchFromGitHub, autoconf, automake, libtool, libxml2, libxslt
, pkg-config, flex, pcre, pcre-cpp, autoreconfHook }:
stdenv.mkDerivation rec {
  pname = "lttoolbox";
  version = "3.5.3";

  src = fetchFromGitHub {
    owner = "apertium";
    repo = "lttoolbox";
    rev = "v${version}";
    sha256 = "1fybcfwmwnddldkmzrqivdjymw1gajw7zsw6c0m21dhfgq9f1l6l";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];

  buildInputs = [ autoconf automake libtool libxml2 libxslt flex pcre pcre-cpp ];

  meta = with lib; {
    description = "Finite state compiler, processor and helper tools used by apertium";
    homepage = "https://github.com/apertium/lttoolbox";

    license = licenses.gpl2;
    maintainers = [  ];
    platforms = platforms.linux;
  };
}
