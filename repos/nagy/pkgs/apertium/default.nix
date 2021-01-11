{ stdenv, lib, fetchFromGitHub, callPackage, autoconf, automake, libtool, libxml2
, libxslt, pkg-config, flex, pcre, pcre-cpp, icu, lttoolbox, autoreconfHook }:
stdenv.mkDerivation rec {
  pname = "apertium";
  version = "3.7.1";

  src = fetchFromGitHub {
    owner = "apertium";
    repo = "apertium";
    rev = "v${version}";
    sha256 = "02cvf9dhg13ml1031apkfaygbm1qvcgh9v1k7j9yr3c7iww3hywf";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];

  buildInputs = [ autoconf automake libtool libxml2 libxslt flex pcre pcre-cpp icu
                  lttoolbox ];

  meta = with lib; {
    description = "A free/open-source machine translation platform";
    homepage = "https://github.com/apertium/apertium";

    license = licenses.gpl2;
    maintainers = [  ];
    platforms = platforms.linux;
  };
}
