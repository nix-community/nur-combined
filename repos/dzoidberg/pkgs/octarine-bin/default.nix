pkgs@{ stdenv, lib, wrapGAppsHook3, zstd, autoPatchelfHook, makeWrapper, desktop-file-utils, openssl, glib, gtk3, libsoup_3, webkitgtk_4_1, libappindicator,fetchurl}:

stdenv.mkDerivation rec {
  pname = "octarine";
  version = "0.49.0";

  src = fetchurl {
    url = "https://pub-3d35bc018fc54f11bde129e3e73e8002.r2.dev/${version}/linux/Octarine-bin-${version}-1-x86_64.pkg.tar.zst";
    hash = "sha256-hUiKn0mGVDj3yoi6ITM+ffoN36ok5Ak9Oiukk6tbFD0=";
  };

  nativeBuildInputs = [ zstd autoPatchelfHook wrapGAppsHook3 makeWrapper ];

  buildInputs = [
    openssl
    glib
    gtk3
    libsoup_3
    webkitgtk_4_1
  ];
  runtimeDependencies = with pkgs; [
    libappindicator
     # not detected by autopatchelf, so specified here
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 usr/bin/octarine "$out/bin/octarine"
    
    install -Dm644 usr/share/icons/hicolor/128x128/apps/octarine.png "$out/share/icons/hicolor/128x128/apps/octarine.png"
    install -Dm644 usr/share/icons/hicolor/256x256@2/apps/octarine.png "$out/share/icons/hicolor/256x265/apps/octarine.png"
    install -Dm644 usr/share/icons/hicolor/32x32/apps/octarine.png "$out/share/icons/hicolor/32x32/apps/octarine.png"

    install -Dm644 usr/share/applications/Octarine.desktop "$out/share/applications/Octarine.desktop"


    runHook postInstall
  '';
  postFixup = ''
    wrapProgram $out/bin/octarine $wrapperfile \
     --prefix PATH : ${lib.makeBinPath [ desktop-file-utils ]}
  ''; # https://github.com/tauri-apps/plugins-workspace/issues/2922 
  meta = with lib; {
    homepage = "https://octarine.app/";
    description = "Octarine Editor";
    mainProgram = "octarine";
    platforms = platforms.linux;
    sourceProvenance = sourceTypes.binaryNativeCode;
    license = licenses.unfreeRedistributable;
  };
}
