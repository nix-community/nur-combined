{ stdenv, fetchFromGitHub,
 } :

stdenv.mkDerivation rec {
  version = "git";
  pname = "superdiskindex";

  src = fetchFromGitHub {
    owner = "shamada-code";
    repo = "${pname}";
    rev = "ce5785a92ddf886ec1e340553b73d43f14e3eb87";
    sha512 = "20p5q6r6i01vpj6lvyx880hnvrjjslbfhfvxbbr675698kxi0hqdq45zgay8dg4cx4zkd54cslp10adjp6rwp2iv69p1a1vkqlaza77";
  };

  buildInputs = [  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -p superdiskindex $out/bin/
    '';

  meta = {
    homepage = https://github.com/shamada-code/superdiskindex;
    description  = "";
    #license = stdenv.lib.licenses.gpl3;
    maintainers = with stdenv.lib.maintainers; [ tokudan ];
    platforms = stdenv.lib.platforms.all;
  };
}
