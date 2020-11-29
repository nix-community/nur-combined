{ stdenv, fetchfromgh, unzip, sdkVersion ? "10.13" }:

assert stdenv.lib.assertOneOf "sdkVersion" sdkVersion [ "10.13" "10.14" "10.15" "11.0.1" ];

stdenv.mkDerivation rec {
  pname = "qmapshack-bin";
  version = "1.15.1";

  src = fetchfromgh {
    owner = "Maproom";
    repo = "qmapshack";
    version = "V_${version}";
    name = "QMapShack_OSX.${sdkVersion}_${version}.zip";
    sha256 = {
      "10.13" = "0yxciyjx30ba9dydy4dad7llybisnab134895wwbxf42mbmsh9wp";
      "10.14" = "0pp4zl6rpkxkzik900x8izjn54nm3q33shqjq89z00rcjmy3xl57";
      "10.15" = "0lz4d7x7f2kx4wpxnmpdpzydalkysj5vnlswlc14q5jrdggsp3j5";
      "11.0.1" = "1jcgcav8zax123i0pz7wp08xmjckm02avb20bfq733hfxd3j6yg4";
    }.${sdkVersion};
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
