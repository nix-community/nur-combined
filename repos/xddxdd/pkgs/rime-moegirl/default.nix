{ stdenv
, fetchurl
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "rime-moegirl";
  version = "20211116";
  src = fetchurl {
    url = "https://github.com/outloudvi/mw2fcitx/releases/download/${version}/moegirl.dict.yaml";
    sha256 = "12f6yia8q6jsgz5g3rl99fy26xvl0shkh8m0nc4wi2xk91fpwmvm";
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/share/rime-data
    cp ${src} $out/share/rime-data/moegirl.dict.yaml
  '';
}
