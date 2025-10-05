{
  lib,
  stdenv,
  fetchfromgh,
  appimageTools,
  undmg,
}:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "goldencheetah-bin";
  version = "3.5";

  suffix =
    {
      x86_64-linux = "amd64_Linux.AppImage";
      x86_64-darwin = "64bit_MacOS.dmg";
    }
    .${system} or throwSystem;

  src = fetchfromgh {
    owner = "GoldenCheetah";
    repo = "GoldenCheetah";
    tag = "V${version}";
    name = "GoldenCheetah_v${version}_${suffix}";
    sha256 =
      {
        x86_64-linux = "07ixivsp5j05a3zsbqx5jf11x7m3rcqaw095qjqrwd0nq0nmmhg8";
        x86_64-darwin = "0alg0a071lpkx0v3qqkqbb93vh1nsb3d7czxl9m15v17akp8nl82";
      }
      .${system} or throwSystem;
  };

  appimageContents = appimageTools.extract { inherit pname version src; };

  meta = {
    description = "Performance software for cyclists, runners and triathletes";
    homepage = "https://www.goldencheetah.org/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
    ];
    skip.ci = true;
  };

  linux = appimageTools.wrapType2 rec {
    inherit
      pname
      version
      src
      meta
      ;

    extraInstallCommands = ''
      mv $out/bin/{${pname}-${version},goldencheetah}
      install -Dm644 ${appimageContents}/GoldenCheetah.desktop -t $out/share/applications
      install -Dm644 ${appimageContents}/gc.png -t $out/share/icons/hicolor/256x256/apps
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit pname version meta;

    preferLocalBuild = true;

    nativeBuildInputs = [ undmg ];

    installPhase = ''
      mkdir -p $out/Applications/GoldenCheetah.app
      cp -r . $out/Applications/GoldenCheetah.app
    '';
  };
in
if stdenv.isDarwin then darwin else linux
