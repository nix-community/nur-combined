{ lib
, stdenv
, fetchFromGitHub
, fuse
, icu66
, autoconf
, automake
, libtool
, pkg-config
, libxml2
, libuuid
, net-snmp
}:

stdenv.mkDerivation rec {
  pname = "ltfs";
  version = "v2.4.5.0-10502";

  src = fetchFromGitHub {
    rev = version;
    owner = "LinearTapeFileSystem";
    repo = "ltfs";
    sha256 = "sha256-FoIghaHq140CSAkTn/pKw2kV/vDORbKiT7ApWJBqIoo=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
    net-snmp
  ];

  buildInputs = [
    fuse
    icu66
    libxml2
    libuuid
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  meta = with lib; {
    description = "Reference LTFS implementation";
    homepage = "https://github.com/LinearTapeFileSystem/ltfs";
    license = licenses.bsd3;
    maintainers = [ "JuniorIsAJitterbug" ];
    platforms = platforms.linux;
    downloadPage = "https://github.com/LinearTapeFileSystem/ltfs";
  };
}
