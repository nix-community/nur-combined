{ stdenv
, lib
, fetchurl
, gfortran
}:

stdenv.mkDerivation rec {

  name = "sprng";

  version = "2.0b";

  src = fetchurl {
    url = "http://sprng.org/Version2.0/sprng2.0b.tar.gz";
    sha256 = "1hhs2c24f5yclps32rrrgl2h4si2xpgi3fn7kf45f3zjwk5dg1c9";
  };

  nativeBuildInputs = [ gfortran ];

  prePatch = ''
    substituteInPlace make.CHOICES --replace "PMLCGDEF" "#PMLCGDEF" --replace "GMPLIB" "#GMPLIB"
  '';

  configurePhase = "";

  buildPhase = "pushd SRC; make CC=cc F77=gfortran FFXN=-DAdd_; popd";

  installPhase = ''
    mkdir -p $out/include
    mkdir -p $out/lib
    mv include/*.h $out/include
    mv lib/libsprng.a $out/lib
  '';

  meta = with lib; {
    description = "The Scalable Parallel Random Number Generators Library";
    homepage = "http://www.sprng.org";
    license = licenses.cc-by-sa-40;
  };

}
