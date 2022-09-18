{ stdenvNoCC
, lib
, fetchurl
, ...
}:

stdenvNoCC.mkDerivation {
  pname = "fcitx5-breeze";
  version = "2.0.0";
  src = fetchurl {
    url = "https://github.com/scratch-er/fcitx5-breeze/releases/download/v2.0.0/fcitx5-breeze-prebuilt-2.0.0.tar.gz";
    sha256 = "0wwwvq90dcb21avdgcqq5w192ndr2m5fmswxblm3l2vcrh36h3jz";
  };
  installPhase = ''
    mkdir $out
    ./install.sh $out
  '';

  meta = with lib; {
    description = "Fcitx5 theme to match KDE's Breeze style";
    homepage = "https://github.com/scratch-er/fcitx5-breeze";
    license = licenses.gpl3;
  };
}
