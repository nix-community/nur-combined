{
  lib,
  pkgs,
  wineWow64Packages,
  wine ? wineWow64Packages.full,
  copyDesktopItems,
  fetchurl,
  makeDesktopItem,
  libarchive,
  stdenv,
  writeShellApplication,
  coreutils,
  curl,
  git,
  gnused,
  jq,
  nix,
  nixfmt,
}:

let
  myLib = import ../../../lib { inherit pkgs; };
  inherit (myLib) mkWindowsAppNoCC;
in
mkWindowsAppNoCC rec {
  inherit wine;
  pname = "paint-net";
  version = "5.2";

  src = stdenv.mkDerivation {
    pname = "${pname}-src";
    inherit version;
    src = fetchurl {
      url = "https://github.com/paintdotnet/release/releases/download/v${version}/paint.net.${version}.portable.x64.zip";
      hash = "sha256-Jomk/lj5FgXSEMRIHxb7UDtvatTt1/OXJRyNnn3okos=";
    };
    nativeBuildInputs = [ libarchive ];
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
    $WINE start /unix "$WINEPREFIX/drive_c/Program Files/paint.net/paintdotnet.exe" "''${ARGS[@]}"
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

  passthru.updateScript = writeShellApplication {
    name = "update-paint-net";
    runtimeInputs = [
      coreutils
      curl
      git
      gnused
      jq
      nix
      nixfmt
    ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="paint-net"
      exec bash ${./update.sh} "$@"
    '';
  };

  meta = with lib; {
    mainProgram = pname;
    homepage = "https://www.getpaint.net/";
    description = "Image and photo editing software";
    license = licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ "maydayv7" ];
    platforms = [
      "x86_64-linux"
    ];
  };
}
