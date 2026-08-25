{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  undmg,
  makeWrapper,
  commandLineArgs ? "",
  steam-run,
}:

let
  inherit (stdenv) hostPlatform;
  version = "3.17.19";
  pname = "cursor";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://downloads.cursor.com/production/ae3a2b7231dd56194447fe4570dfdc61640b1e9a/linux/x64/Cursor-3.17.19-x86_64.AppImage";
      hash = "sha256-kB38QeH6+HK05tSift0Uk62Ob5x1Jwswp/yvVjwk6D8=";
    };
    x86_64-darwin = fetchurl {
      url = "https://downloads.cursor.com/production/ae3a2b7231dd56194447fe4570dfdc61640b1e9a/darwin/x64/Cursor-darwin-x64.dmg";
      hash = "sha256-/49cyDWaaNTkXfFT/e0FqotYCb7KXPNhaYF7vI8WJUw=";
    };
    aarch64-darwin = fetchurl {
      url = "https://downloads.cursor.com/production/ae3a2b7231dd56194447fe4570dfdc61640b1e9a/darwin/arm64/Cursor-darwin-arm64.dmg";
      hash = "sha256-v2ZvHmKRJMXbsuSjRgS/11Z58YuyhVa8DmhwoGPJP8U=";
    };
  };

  source = sources.${hostPlatform.system};

  linux = appimageTools.wrapType2 {
    inherit pname version;
    src = source;

    extraInstallCommands =
      let
        contents = appimageTools.extract { inherit pname version; src = source; };
      in
      ''
        # Wrap cursor with steam-run for FHS compatibility
        mv $out/bin/${pname} $out/bin/${pname}-unwrapped
        makeWrapper ${steam-run}/bin/steam-run $out/bin/${pname} \
          --add-flags "$out/bin/${pname}-unwrapped" \
          --add-flags "--update=false ${commandLineArgs}"

        # Install desktop file and icons
        install -Dm444 ${contents}/usr/share/cursor/resources/app/resources/linux/code.png $out/share/pixmaps/cursor.png
        install -Dm444 ${contents}/cursor.desktop $out/share/applications/cursor.desktop
        substituteInPlace $out/share/applications/cursor.desktop \
          --replace-fail 'Exec=AppRun' 'Exec=cursor'
      '';

    nativeBuildInputs = [ makeWrapper ];
  };

  darwin = stdenv.mkDerivation {
    inherit pname version;
    src = source;

    nativeBuildInputs = [ undmg ];

    sourceRoot = "Cursor.app";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications/Cursor.app
      cp -R . $out/Applications/Cursor.app
      mkdir -p $out/bin
      ln -s "$out/Applications/Cursor.app/Contents/MacOS/Cursor" $out/bin/cursor
      runHook postInstall
    '';

    # Editing the binary causes the bundle's signature to be invalidated
    dontFixup = true;
  };

in
(if hostPlatform.isDarwin then darwin else linux).overrideAttrs (oldAttrs: {
  passthru = (oldAttrs.passthru or { }) // {
    inherit sources;
    updateScript = ./update.sh;
  };

  meta = {
    description = "AI-powered code editor built on vscode";
    homepage = "https://cursor.com";
    changelog = "https://cursor.com/changelog";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ] ++ lib.platforms.darwin;
    mainProgram = "cursor";
  };
})
