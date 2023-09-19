{ lib
, stdenv
, fetchFromGitHub
, cmake
, ninja
, libzypp
}:

stdenv.mkDerivation rec {
  pname = "zypper";
  version = "1.14.64";

  src = fetchFromGitHub {
    owner = "opensuse";
    repo = "zypper";
    rev = version;
    hash = "sha256-WI1sG0xe7Vd7ufRtT9NU5I418JUfJNO56mFOM6MCynM=";
  };

  nativeBuildInputs = [
    cmake
    ninja
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
