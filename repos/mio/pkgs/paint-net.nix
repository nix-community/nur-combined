{
  lib,
  build,
  pkgs,
  wine,
  ...
}:
let
  inherit (pkgs) copyDesktopItems fetchurl makeDesktopItem;
  inherit (build) makeDesktopIcon mkWindowsAppNoCC;
in
mkWindowsAppNoCC rec {
  inherit wine;
  pname = "paint-net";
  version = "5.1.12";

  src = pkgs.stdenv.mkDerivation {
    pname = "${pname}-src";
    inherit version;
    src = fetchurl {
      url = "https://github.com/paintdotnet/release/releases/download/v${version}/paint.net.${version}.portable.x64.zip";
      hash = "sha256-1a5wQ/L7nTZbSN/iQ6KsocdJJN6ZsEtkRZFslTVK76M=";
    };
    nativeBuildInputs = [ pkgs.libarchive ];
    unpackPhase = ''
      mkdir -p source
      bsdtar -xf $src -C source
    '';
    installPhase = ''
      mkdir -p $out
      cp -r source/* $out/
    '';
  };

  dontUnpack = true;
  wineArch = "win64";

  persistRegistry = true;

  fileMap = {
    "$HOME/.config/paint.net" = "drive_c/users/$USER/AppData/Local/paint.net";
  };

  enableMonoBootPrompt = false;

  nativeBuildInputs = [
    copyDesktopItems
  ];

  winAppInstall = ''
    mkdir -p "$WINEPREFIX/drive_c/Program Files/paint.net"
    cp -r ${src}/* "$WINEPREFIX/drive_c/Program Files/paint.net/"
    wineserver -w
  '';

  winAppRun = ''
    $WINE start /unix "$WINEPREFIX/drive_c/Program Files/paint.net/paintdotnet.exe" "$ARGS"
  '';

  installPhase = ''
    runHook preInstall
    mv $out/bin/.launcher $out/bin/${pname}
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "paint.net";
      exec = pname;
      icon = pname;
      desktopName = "paint.net";
      genericName = "Image Editor";
      mimeTypes = [
        "image/png"
        "image/jpeg"
        "image/bmp"
      ];
      categories = [
        "Graphics"
        "2DGraphics"
        "RasterGraphics"
      ];
    })
  ];

  meta = with lib; {
    mainProgram = pname;
    homepage = "https://www.getpaint.net/";
    description = "Image and photo editing software";
    license = licenses.freeware;
    maintainers = [ "maydayv7" ];
    platforms = [
      "x86_64-linux"
    ];
  };
}
