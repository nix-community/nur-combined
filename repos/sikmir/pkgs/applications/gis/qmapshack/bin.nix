{ stdenv, fetchfromgh, unzip }:
let
  pname = "qmapshack";
  version = "1.15.0";
  sha256 = "0dhl2km0xbv77xabjwdiv3y1psbjwjlyqs5222ji5d33wxl8m07n";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchfromgh {
    owner = "Maproom";
    repo = pname;
    version = "V_${version}";
    name = "QMapShack_OSX.${stdenv.appleSdkVersion}_${version}.zip";
    inherit sha256;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
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
