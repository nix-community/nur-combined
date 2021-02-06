{ stdenv, lib, fetchurl, unzip }:

let
  description = "Wingdings font.";
in stdenv.mkDerivation rec {
  name = "wingdings-${version}";
  version = "2015-11-10";

  src = fetchurl {
    url = https://www.wfonts.com/download/data/2015/11/10/wingdings/wingdings.zip;
    sha256 = "16r6dq97q55zbmm1f1f42bd29v8vin3slgvjpc0h72ky285ha3ss";
  };

  nativeBuildInputs = [ unzip ];

  unpackCmd = ''
    mkdir wingdings
    pushd wingdings
    unzip $curSrc
    popd
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/wingdings

    cp -r ./*.ttf $out/share/fonts/wingdings
  '';

  meta = with lib; {
    inherit description;
    homepage = https://www.wfonts.com/font/wingdings;
    license = licenses.unfree;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
