{ stdenv, fetchfromgh, unzip }:
let
  pname = "qmapshack";
  version = "1.15.0";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchfromgh {
    owner = "Maproom";
    repo = "qmapshack";
    version = "V_${version}";
    name = "QMapShack_OSX.${stdenv.appleSdkVersion}_${version}.zip";
    sha256 = "0dhl2km0xbv77xabjwdiv3y1psbjwjlyqs5222ji5d33wxl8m07n";
  };

  unpackPhase = "${unzip}/bin/unzip $src";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r QMapShack.app QMapTool.app $out/Applications
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/Maproom/qmapshack";
    description = "Consumer grade GIS software";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
