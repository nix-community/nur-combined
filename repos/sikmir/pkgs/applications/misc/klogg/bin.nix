{ lib, stdenv, fetchfromgh, appimageTools, undmg }:
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
    name = "klogg-${version}.0.813-${suffix}";
    sha256 = {
      x86_64-linux = "1m0yl6bd6ahxqljqfjvd6p9nm4vyr4pyrr1qzm70nn2rn4vi4w83";
      x86_64-darwin = "07iyg1i6n5ydg99q75wlbl1jh1n1cdjl3rbia2kx6y7dg80lx0d1";
    }.${system} or throwSystem;
  };

  appimageContents = appimageTools.extract {
    inherit name src;
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
