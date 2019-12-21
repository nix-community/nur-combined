{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  version = "14-137";
  name = "mcl-${version}";
  src = fetchurl {
    url = "https://micans.org/mcl/src/mcl-14-137.tar.gz";
    sha256 = "sha256:15xlax3z31lsn62vlg94hkm75nm40q4679amnfg13jm8m2bnhy5m";
  };

  configureFlags = [ "--enable-blast" ];

  meta = with stdenv.lib; {
    platforms = platforms.linux;
  };
}
