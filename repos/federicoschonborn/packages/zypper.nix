{ lib
, stdenv
, fetchFromGitHub
, cmake
, libzypp
}:

stdenv.mkDerivation rec {
  pname = "zypper";
  version = "1.14.62";

  src = fetchFromGitHub {
    owner = "opensuse";
    repo = "zypper";
    rev = version;
    hash = "sha256-u/yyFrNA0JjJMdFc+0YipVv0b4rLL+N9K6VP/k6tQ34=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    libzypp
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
    broken = true;
  };
}
