{ lib, stdenv, fetchfromgh, appimageTools, undmg }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "klogg-bin";
  version = "22.06";

  suffix = {
    x86_64-linux = "Linux-amd64.AppImage";
    x86_64-darwin = "OSX-Qt5.dmg";
  }.${system} or throwSystem;

  src = fetchfromgh {
    owner = "variar";
    repo = "klogg";
    version = "v${version}";
    name = "klogg-${version}.0.1289-${suffix}";
    hash = {
      x86_64-linux = "sha256-XawJ6VOF0XtMrl7iefm13quv83X171k9eKiXClrklZI=";
      x86_64-darwin = "sha256-5d93ItDYUYUt2cw0Sd1C0f7z507dqMINwEs4y4UrD+w=";
    }.${system} or throwSystem;
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

  meta = with lib; {
    description = "A fast, advanced log explorer based on glogg project";
    homepage = "https://klogg.filimonov.dev/";
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };

  linux = appimageTools.wrapType2 rec {
    inherit pname version src meta;

    extraInstallCommands = ''
      mv $out/bin/{${pname}-${version},klogg}
      install -Dm644 ${appimageContents}/klogg.desktop -t $out/share/applications
      install -Dm644 ${appimageContents}/klogg.png -t $out/share/icons/hicolor/scalable/apps
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit pname version src meta;

    nativeBuildInputs = [ undmg ];

    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/Applications
      cp -r *.app $out/Applications
    '';
  };
in
if stdenv.isDarwin
then darwin
else linux
