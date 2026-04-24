{ lib, stdenv, fetchurl, appimageTools, undmg }:

let
  inherit (stdenv) hostPlatform;
  pname = "t3code";
  version = "0.0.21";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/pingdotgg/t3code/releases/download/v0.0.21/T3-Code-0.0.21-x86_64.AppImage";
      hash = "sha256-eQCfskpl+JJOyaYY7ogYCi0ZCuWNRcEpseWMniS/LCQ=";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/pingdotgg/t3code/releases/download/v0.0.21/T3-Code-0.0.21-x64.dmg";
      hash = "sha256-v2Ee75uVOJgRit1l/TZoHU9/1Kc2gHdJfUYHseCqJj8=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/pingdotgg/t3code/releases/download/v0.0.21/T3-Code-0.0.21-arm64.dmg";
      hash = "sha256-8GsNf5n1sh1X444KxnIAQmFCKG3SUbMWK6pyXzUOp9w=";
    };
  };

  source =
    sources.${hostPlatform.system}
      or (throw "t3code: unsupported system ${hostPlatform.system}");

  linux = appimageTools.wrapType2 {
    inherit pname version;
    src = source;

    extraInstallCommands =
      let
        contents = appimageTools.extract {
          inherit pname version;
          src = source;
        };
      in
      ''
        install -Dm444 ${contents}/.DirIcon $out/share/pixmaps/t3code.png

        desktop_file="$(echo ${contents}/*.desktop)"
        install -Dm444 "$desktop_file" $out/share/applications/t3code.desktop
        substituteInPlace $out/share/applications/t3code.desktop \
          --replace-fail 'Exec=AppRun' 'Exec=t3code'
        sed -i 's|^Icon=.*|Icon=t3code|' $out/share/applications/t3code.desktop
      '';
  };

  darwin = stdenv.mkDerivation {
    inherit pname version;
    src = source;

    nativeBuildInputs = [ undmg ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/Applications" "$out/bin"

      app_bundle="$(echo *.app)"
      cp -R "$app_bundle" "$out/Applications/"

      app_executable="$(echo "$out/Applications/$app_bundle/Contents/MacOS/"*)"
      ln -s "$app_executable" "$out/bin/t3code"

      runHook postInstall
    '';

    # Editing the binary would invalidate the upstream app signature.
    dontFixup = true;
  };
in
(if hostPlatform.isDarwin then darwin else linux).overrideAttrs (_: {
  passthru = {
    inherit sources;
    updateScript = ../../scripts/update-t3code.sh;
  };

  meta = with lib; {
    description = "Desktop GUI for coding agents like Codex and Claude";
    homepage = "https://github.com/pingdotgg/t3code";
    changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${version}";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = [ "lmdevv" ];
    platforms = [ "x86_64-linux" ] ++ platforms.darwin;
    mainProgram = "t3code";
  };
})
