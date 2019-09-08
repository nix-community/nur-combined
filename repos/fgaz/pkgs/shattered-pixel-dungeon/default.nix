{ stdenv
, fetchurl
, makeWrapper
, jre
, xorg
, openal
}:

stdenv.mkDerivation rec {
  pname = "shattered-pixel-dungeon";
  version = "0.7.4c";
  src = fetchurl {
    url = "https://github.com/00-Evan/shattered-pixel-dungeon-gdx/releases/download/v${version}/ShatteredPD.Desktop.v${version}.jar";
    sha256 = "0lsfgb07zjakqji0swv2vv5pcxz95r5zkdr374v25z3vc00ap0yy";
  };
  unpackCmd = "mkdir source; cp $curSrc source/ShatteredPD.Desktop.jar";
  nativeBuildInputs = [
    makeWrapper
  ];
  dontBuild = true;
  installPhase = ''
    install -Dm644 ShatteredPD.Desktop.jar $out/share/shattered-pixel-dungeon.jar
    mkdir $out/bin
    makeWrapper ${jre}/bin/java $out/bin/shattered-pixel-dungeon \
      --prefix LD_LIBRARY_PATH : ${xorg.libXxf86vm}/lib:${openal}/lib \
      --add-flags "-jar $out/share/shattered-pixel-dungeon.jar"
  '';

  meta = with stdenv.lib; {
    homepage = "https://shatteredpixel.com/";
    downloadPage = "https://github.com/00-Evan/shattered-pixel-dungeon-gdx/releases";
    description = "Traditional roguelike game with pixel-art graphics and simple interface";
    license = licenses.gpl3;
    maintainers = with maintainers; [ fgaz ];
  };
}

