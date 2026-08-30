{ lib, stdenv, fetchurl, appimageTools, undmg }:

let
  inherit (stdenv) hostPlatform;
  pname = "t3code";
  version = "0.0.37-lmdevv.20260830.4";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/lmdevv/t3code/releases/download/v0.0.37-lmdevv.20260830.4/T3-Code-0.0.37-lmdevv.20260830.4-x86_64.AppImage";
      hash = "sha256-OH8bpaN06goyQCRlmTrEijwZ9u5j1gMMLt1IEWG8448=";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/lmdevv/t3code/releases/download/v0.0.37-lmdevv.20260830.4/T3-Code-0.0.37-lmdevv.20260830.4-x64.dmg";
      hash = "sha256-Fu4uy9ytOIXWaeRT07iCCUykD8LxPZZrX4hlaj58BUI=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/lmdevv/t3code/releases/download/v0.0.37-lmdevv.20260830.4/T3-Code-0.0.37-lmdevv.20260830.4-arm64.dmg";
      hash = "sha256-GHip6syznWKgsv9x1c1DSSYiTR5TdZamxTaGdB8j2uQ=";
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
    homepage = "https://github.com/lmdevv/t3code";
    changelog = "https://github.com/lmdevv/t3code/releases/tag/v${version}";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = [ "lmdevv" ];
    platforms = [ "x86_64-linux" ] ++ platforms.darwin;
    mainProgram = "t3code";
  };
})
