{ stdenv, fetchurl, coreutils, gnused, which }:

stdenv.mkDerivation rec {
  name = "toybox-${version}";
  version = "0.8.0";

  src = fetchurl {
    url = "http://landley.net/toybox/downloads/${name}.tar.gz";
    sha256 = "0mirj977zxsxnfaiqndwgsn9calgg312d817fi1hkfbd8kcyrk73";
  };

  postPatch = "patchShebangs .";

  configurePhase = "make defconfig";

  nativeBuildInputs = [ gnused coreutils which ];

  makeFlags = [ "VERBOSE=1" "PREFIX=${placeholder "out"}/bin" ];

  doCheck = false;
  checkTarget = "tests";

  installTargets = [ "install_flat" ];

  meta = with stdenv.lib; {
    description = "Common linux utilities in a multicall binary";
    homepage = https://landley.net/toybox/;
    license = licenses.bsd2;
    maintainers = with maintainers; [ dtzWill ];
  };
}
