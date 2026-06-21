{
  lib,
  python3Packages,
  bash,
  fetchFromGitHub,
  gsettings-desktop-schemas,
  scrcpy,
  gtk3,
  makeDesktopItem,
  makeBinaryWrapper,
  libadwaita,
}:

python3Packages.buildPythonApplication rec {
  pname = "PixelFlasher";
  version = "v9.1.1.2";
  src = fetchFromGitHub {
    owner = "badabing2005";
    repo = "PixelFlasher";
    rev = "${version}";
    sha256 = "sha256-n/5Qmav/x9/ZcMDW05NFdga2VfFrz3fZ8J7qqXKSi74=";
  };
  nativeBuildInputs = [
    makeBinaryWrapper
    bash
  ];
  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    icon = "pixelflasher";
    desktopName = "PixelFlasher";
    categories = [ "Utility" ];
    comment = "Flash Android devices BROWSE BUTTON CRASHES";
  };
  pyproject = false;
  build-system = [
    python3Packages.pyinstaller
    python3Packages.pyinstaller-versionfile
  ];
  dependencies = [
    python3Packages.attrdict
    python3Packages.pyinstaller
    python3Packages.httplib2
    python3Packages.pyinstaller-versionfile
    python3Packages.platformdirs
    python3Packages.requests
    python3Packages.darkdetect
    python3Packages.markdown
    python3Packages.pyperclip
    python3Packages.protobuf
    python3Packages.six
    python3Packages.bsdiff4
    python3Packages.lz4
    python3Packages.psutil
    python3Packages.json5
    python3Packages.beautifulsoup4
    python3Packages.chardet
    python3Packages.cryptography
    python3Packages.rsa
    python3Packages.polib
    python3Packages.wxpython
    scrcpy
    gtk3
    gsettings-desktop-schemas
    libadwaita
  ];
  buildPhase = ''
    runHook preBuild
    bash build.sh
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 dist/PixelFlasher $out/bin
    install -Dm644 images/icon-dark-256.png $out/share/icons/hicolor/pixelflasher.png
    wrapProgram $out/bin/PixelFlasher \
     --prefix PATH : ${
       lib.makeBinPath [
         scrcpy
       ]
     } \
     --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath dependencies}
    runHook postInstall
  '';
}
