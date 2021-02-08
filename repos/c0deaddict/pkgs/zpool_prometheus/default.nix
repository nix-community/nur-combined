{ lib, stdenv, fetchFromGitHub, cmake, zfs }:

stdenv.mkDerivation rec {
  name = "zpool_prometheus";
  version = "87de63e214c91a66efd2add6a630436d95700872";

  src = fetchFromGitHub {
    owner = "richardelling";
    repo = name;
    rev = version;
    sha256 = "1n8dwsxq9mklp7nhy1b3mmx1m8vkkphkbsax2y7392dgdvwsb6hr";
  };

  cmakeFlags = [ "-DZFS_INSTALL_BASE=${zfs.dev}" ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ zfs ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp zpool_prometheus $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/richardelling/zpool_prometheus";
    description = "Prometheus-style metrics scraper for ZFS pools";
    maintainers = with maintainers; [ c0deaddict ];
    license = licenses.mit;
  };

}
