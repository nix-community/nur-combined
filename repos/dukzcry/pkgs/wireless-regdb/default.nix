{ lib, stdenvNoCC, fetchurl, openssl, python3 }:

let
  db = ./db.txt;
in stdenvNoCC.mkDerivation rec {
  pname = "wireless-regdb";
  version = "2023.05.03";

  src = fetchurl {
    url = "https://www.kernel.org/pub/software/network/${pname}/${pname}-${version}.tar.xz";
    sha256 = "sha256-8lTQirN2WuriuFYiLhGpXUSu9RmmZjh3xx72j65MjBI=";
  };

  nativeBuildInputs = [ openssl (python3.withPackages (p: with p; [ m2crypto ])) ];

  preBuild = ''
    rm db.txt
    cp ${db} db.txt
    export HOME=`pwd`/tmp
    mkdir -p $HOME
    patchShebangs .
  '';

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
    "PREFIX="
  ];

  postInstall = ''
    openssl x509 -in ./custom-user.x509.pem -outform DER -out $out/lib/crda/pubkeys/custom-user.x509
  '';

  meta = with lib; {
    description = "Wireless regulatory database for CRDA";
    homepage = "http://wireless.kernel.org/en/developers/Regulatory/";
    license = licenses.isc;
    platforms = platforms.all;
    maintainers = with maintainers; [ ];
  };
}
