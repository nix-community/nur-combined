{
  lib,
  stdenv,
  appimageTools,
  fetchfromgh,
  undmg,
  makeWrapper,
}:

let
  pname = "mqtt-explorer";
  version = "0.3.5";

  srcs = {
    x86_64-linux = fetchfromgh {
      owner = "thomasnordquist";
      repo = "MQTT-Explorer";
      name = "MQTT-Explorer-${version}.AppImage";
      version = "v${version}";
      hash = "sha256-Yfz42+dVIx3xwIOmYltp5e9rYka+KskvQuxJVVBgbg4=";
    };
    x86_64-darwin = fetchfromgh {
      owner = "thomasnordquist";
      repo = "MQTT-Explorer";
      name = "MQTT-Explorer-${version}.dmg";
      version = "v${version}";
      hash = "sha256-Cf2qgoxaNGpcaW0oA605vd5zQiZX1m54ccW8Tbe8qvU=";
    };
  };
  src =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  appimageContents = appimageTools.extract { inherit pname version src; };

  linux = appimageTools.wrapType2 rec {
    inherit
      pname
      version
      src
      meta
      ;

    extraInstallCommands = ''
      mv $out/bin/${pname}-${version} $out/bin/${pname}

      install -Dm444 ${appimageContents}/mqtt-explorer.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/mqtt-explorer.desktop \
        --replace-fail "Exec=AppRun" "Exec=$out/bin/mqtt-explorer"

      install -Dm444 ${appimageContents}/mqtt-explorer.png -t $out/share/icons/hicolor/512x512/apps
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = [
      undmg
      makeWrapper
    ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      mv *.app $out/Applications
      makeWrapper $out/{Applications/MQTT\ Explorer.app/Contents/MacOS/MQTT\ Explorer,bin/mqtt-explorer}
      runHook postInstall
    '';
  };

  meta = {
    description = "An all-round MQTT client that provides a structured topic overview";
    homepage = "https://mqtt-explorer.com/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.cc-by-40;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = builtins.attrNames srcs;
    mainProgram = "mqtt-explorer";
    skip.ci = true;
  };
in
if stdenv.isDarwin then darwin else linux
