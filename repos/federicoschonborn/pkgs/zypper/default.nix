{ lib
, stdenv
, fetchFromGitHub
, asciidoctor
, cmake
, gettext
, ninja
, augeas
, boost
, libxml2
, libzypp
, readline
, rpm
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zypper";
  version = "1.14.66";

  src = fetchFromGitHub {
    owner = "opensuse";
    repo = "zypper";
    rev = finalAttrs.version;
    hash = "sha256-35Uv0ekUgNOcDijuys0NZNY9NKyGyftxyS3sbNO++YU=";
  };

  nativeBuildInputs = [
    asciidoctor
    cmake
    gettext
    ninja
  ];

  buildInputs = [
    augeas
    boost
    libxml2
    libzypp
    readline
    rpm
  ];

  cmakeFlags = [
    "-DCMAKE_MODULE_PATH=${libzypp}/share/cmake/Modules"
  ];

  meta = with lib; {
    description = "World's most powerful command line package manager";
    homepage = "https://github.com/opensuse/zypper";
    license = with licenses; [ gpl2Plus ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ federicoschonborn ];
  };
})
