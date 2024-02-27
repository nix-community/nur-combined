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

stdenv.mkDerivation {
  pname = "ltfs";
  version = "v2.4.6.0-10511";

  src = fetchFromGitHub {
    rev = "fd41c66ebf8be18bc8a6d88129d935713e03d42e";
    owner = "LinearTapeFileSystem";
    repo = "ltfs";
    sha256 = "sha256-eCshucE56P7WkJ6FweenGQKR5BvLDUJEtfQtGmNDbts=";
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
    description = "Reference LTFS implementation.";
    homepage = "https://github.com/LinearTapeFileSystem/ltfs";
    license = licenses.bsd3;
    maintainers = [ "JuniorIsAJitterbug" ];
    platforms = platforms.linux;
    downloadPage = "https://github.com/LinearTapeFileSystem/ltfs";
  };
}
