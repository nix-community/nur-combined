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
  version = "3.10.11";
  pname = "cursor";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://downloads.cursor.com/production/4ef9fe3d055f8c4523179a090f14eb835bc3c94e/linux/x64/Cursor-3.10.11-x86_64.AppImage";
      hash = "sha256-H+OAJYH30wnbj81DS20yf6PsXlKSJEAAf2yW7Rq+d30=";
    };
    x86_64-darwin = fetchurl {
      url = "https://downloads.cursor.com/production/4ef9fe3d055f8c4523179a090f14eb835bc3c94e/darwin/x64/Cursor-darwin-x64.dmg";
      hash = "sha256-SIoBbqUJFtxsgY6UJLI+AjoU74tVXC8ez1P4+8SDqsQ=";
    };
    aarch64-darwin = fetchurl {
      url = "https://downloads.cursor.com/production/4ef9fe3d055f8c4523179a090f14eb835bc3c94e/darwin/arm64/Cursor-darwin-arm64.dmg";
      hash = "sha256-Omhpm2H8Nz7ZmT7tFLlXroTowettwAGWhrxyXhUWTnw=";
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
