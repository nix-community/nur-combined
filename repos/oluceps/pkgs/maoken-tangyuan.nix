{ stdenvNoCC
, lib
, fetchurl
, unzip
, ...
} @ args:

stdenvNoCC.mkDerivation rec {
  pname = "maoken-tangyuan";
  version = "0.12beta";
  src = fetchurl ({
    url = "https://github.com/NightFurySL2001/TangYuan-font/releases/download/v0.12beta/MaoKenTangYuan-beta0.12-20210702.zip";
    sha256 = "sha256-ZOrvf/+6KXSHSah6e2KHwGqe/ACpYw4mg32zkqBE9V8=";
  });

  setSourceRoot = "sourceRoot=`pwd`";
  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/share/fonts/{opentype,truetype}/
    find . -name '*.otf' -exec install -Dt $out/share/fonts/opentype {} \;
    find . -name '*.ttf' -exec install -Dt $out/share/fonts/truetype {} \;
    find . -name '*.ttc' -exec install -Dt $out/share/fonts/truetype {} \;
  '';
  meta = with lib; {
    description =
      ''
        TangYuan/MaoKen TangYuan font
      '';
    homepage = "https://open.oppomobile.com/bbs/forum.php?mod=viewthread&tid=2274";
    #    maintainers = with maintainers; [ oluceps ];
  };
}
