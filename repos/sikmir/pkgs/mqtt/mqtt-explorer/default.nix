{ lib, stdenv, appimageTools, fetchurl, undmg, makeWrapper }:

let
  pname = "mqtt-explorer";
  version = "0.3.5";

  srcs = {
    x86_64-linux = fetchurl {
      url = "https://github.com/thomasnordquist/MQTT-Explorer/releases/download/v${version}/MQTT-Explorer-${version}.AppImage";
      hash = "sha256-Yfz42+dVIx3xwIOmYltp5e9rYka+KskvQuxJVVBgbg4=";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/thomasnordquist/MQTT-Explorer/releases/download/v${version}/MQTT-Explorer-${version}.dmg";
      hash = "sha256-Cf2qgoxaNGpcaW0oA605vd5zQiZX1m54ccW8Tbe8qvU=";
    };
  };
  src = srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  appimageContents = appimageTools.extract { inherit pname version src; };

  linux = appimageTools.wrapType2 rec {
    inherit pname version src meta;

    extraInstallCommands = ''
      mv $out/bin/${pname}-${version} $out/bin/${pname}

      install -Dm444 ${appimageContents}/mqtt-explorer.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/mqtt-explorer.desktop \
        --replace "Exec=AppRun" "Exec=$out/bin/mqtt-explorer"

      install -Dm444 ${appimageContents}/mqtt-explorer.png -t $out/share/icons/hicolor/512x512/apps
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit pname version src meta;

    nativeBuildInputs = [ undmg makeWrapper ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      mv *.app $out/Applications
      makeWrapper $out/{Applications/MQTT\ Explorer.app/Contents/MacOS/MQTT\ Explorer,bin/mqtt-explorer}
      runHook postInstall
    '';
  };

  meta = with lib; {
    description = "An all-round MQTT client that provides a structured topic overview";
    homepage = "https://mqtt-explorer.com/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.cc-by-40;
    maintainers = with maintainers; [ sikmir ];
    platforms = builtins.attrNames srcs;
    mainProgram = "mqtt-explorer";
  };
in
if stdenv.isDarwin
then darwin
else linux
