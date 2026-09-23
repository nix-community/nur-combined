{
  lib,
  stdenvNoCC,
  makeWrapper,
  winePackages,
  p7zip,
  imagemagick,
  makeDesktopItem,
  fetchzip,
}:

let
  protocols = [
    "dav"
    "davs"
    "ftp"
    "ftpes"
    "ftps"
    "s3"
    "scp"
    "sftp"
    "ssh"
    "winscp-DAV"
    "winscp-DAVS"
    "winscp-FTP"
    "winscp-FTPES"
    "winscp-FTPS"
    "winscp-HTTP"
    "winscp-HTTPS"
    "winscp-S3"
    "winscp-SCP"
    "winscp-SFTP"
    "winscp-SSH"
    "WinSCP.Url"
  ];
  desktopItemValues = {
    name = "winscp";
    exec = "winscp %u";
    icon = "winscp";
    desktopName = "WinSCP";
    comment = "SFTP, FTP, WebDAV, S3 and SCP client";
    categories = [ "Network" "FileTransfer" ];
    terminal = false;
    type = "Application";
    startupWMClass = "winscp.exe";
    startupNotify = true;
    mimeTypes = map (x: "x-scheme-handler/${x}") protocols;
  };
  desktopItem = makeDesktopItem desktopItemValues;
  # this was an attempt to recreate all the desktop files like wine does it
  # but that was silly, because  i think i don't need to do that
  #fileAssociations = map (protocol: makeDesktopItem (desktopItemValues // {
  #  name = "winscp-protocol-${protocol}";
  #  mimeTypes = [ "x-scheme-handler/${protocol}" ];
  #  noDisplay = true;
  #})) protocols;
in
stdenvNoCC.mkDerivation rec {
  pname = "winscp";
  version = "6.5.7";

  src = fetchzip {
    url = "https://winscp.net/download/WinSCP-6.5.7-Portable.zip/download";
    hash = "sha256-IAr/5FWdC+q8LpIsj5WeSPgslYQRFkpz4NlxdsMW1jw=";
    extension = "zip";
    stripRoot = false;
  };

  nativeBuildInputs = [ makeWrapper p7zip imagemagick ];
  
  passthru = { inherit desktopItemValues desktopItem; };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/{applications,icons/hicolor}}

    # is this stable? it works for at least 6.5.7
    7z x $src/WinSCP.exe
    for f in 256 128 64 60 48 42 40 32 24 20 16; do
      mkdir -p $out/share/icons/hicolor/''${f}x''${f}
    done
    cp .rsrc/1033/ICON/1 $out/share/icons/hicolor/256x256/winscp.png
    magick .rsrc/1033/ICON/2.ico  $out/share/icons/hicolor/128x128/winscp.png
    magick .rsrc/1033/ICON/3.ico  $out/share/icons/hicolor/64x64/winscp.png
    magick .rsrc/1033/ICON/4.ico  $out/share/icons/hicolor/60x60/winscp.png
    magick .rsrc/1033/ICON/5.ico  $out/share/icons/hicolor/48x48/winscp.png
    magick .rsrc/1033/ICON/6.ico  $out/share/icons/hicolor/42x42/winscp.png
    magick .rsrc/1033/ICON/7.ico  $out/share/icons/hicolor/40x40/winscp.png
    magick .rsrc/1033/ICON/8.ico  $out/share/icons/hicolor/32x32/winscp.png
    magick .rsrc/1033/ICON/9.ico  $out/share/icons/hicolor/24x24/winscp.png
    magick .rsrc/1033/ICON/10.ico $out/share/icons/hicolor/20x20/winscp.png
    magick .rsrc/1033/ICON/11.ico $out/share/icons/hicolor/16x16/winscp.png

    makeWrapper ${winePackages.stable}/bin/wine $out/bin/winscp \
      --set WINEDEBUG "-all" \
      --set WINEDLLOVERRIDES "mscoree=d" \
      --run "export WINSCP_DIR=\''${XDG_DATA_HOME:-\$HOME/.local/share}" \
      --run "mkdir -p \$WINSCP_DIR/winscp/wineprefix" \
      --run "touch \$WINSCP_DIR/winscp/WinSCP.ini" \
      --run "export WINEPREFIX=\$WINSCP_DIR/winscp/wineprefix" \
      --add-flags "$src/WinSCP.exe /ini=Z:/\$WINSCP_DIR/winscp/WinSCP.ini"

    ln -s $src $out/share/winscp
    cp ${desktopItem}/share/applications/*.desktop $out/share/applications/
    #''${lib.concatStringsSep "\n" (map (x: "cp ''${x}/share/applications/*.desktop $out/share/applications/") fileAssociations)}

    runHook postInstall
  '';

  meta = {
    description = "SFTP, FTP, WebDAV, S3 and SCP client for Windows (Wine wrapper)";
    homepage = "https://winscp.net";
    license = lib.licenses.gpl3Only; # this is missing the license for WinSCP icons
    platforms = [ "i686-linux" "x86_64-linux" ];
    broken = stdenvNoCC.hostPlatform.isDarwin; # can it even ever work on macOS?
    mainProgram = "winscp";
  };
}
