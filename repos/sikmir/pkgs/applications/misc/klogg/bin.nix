{ stdenv, fetchfromgh, appimageTools, undmg, sources }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "klogg-bin";
  version = "20.12";
  name = "${pname}-${version}";

  suffix = {
    x86_64-linux = "x86_64.AppImage";
    x86_64-darwin = "OSX.dmg";
  }.${system} or throwSystem;

  src = fetchfromgh {
    owner = "variar";
    repo = "klogg";
    version = "v${version}";
    name = "klogg-${version}.0.808-${suffix}";
    sha256 = {
      x86_64-linux = "00xsqhw7dbvnwksl8ll612vn2h604z95syfa75sfc8ha8dsnvcdh";
      x86_64-darwin = "0ig39sqiamrlaf0chn81bbi6z0gy7q0nr8qgaxzzy9ny7j8svip6";
    }.${system} or throwSystem;
  };

  appimageContents = appimageTools.extract {
    inherit name src;
  };

  meta = with stdenv.lib; {
    inherit (sources.klogg) description homepage;
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };

  linux = appimageTools.wrapType2 rec {
    inherit name src meta;

    extraInstallCommands = ''
      mv $out/bin/{${name},klogg}
      install -Dm644 ${appimageContents}/klogg.desktop -t $out/share/applications
      install -Dm644 ${appimageContents}/klogg.svg -t $out/share/icons/hicolor/scalable/apps
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit pname version src meta;

    nativeBuildInputs = [ undmg ];

    sourceRoot = "klogg.app";

    installPhase = ''
      mkdir -p $out/Applications/klogg.app
      cp -r . $out/Applications/klogg.app
    '';
  };
in
if stdenv.isDarwin
then darwin
else linux
