{ lib
, stdenv
, appimageTools
, fetchurl
,
}:
let
  pname = "cursor";
  version = "3.2.21";
  sources = {
    x86_64.url = "https://downloads.cursor.com/production/806df57ed3b6f1ee0175140d38039a38574ec722/linux/x64/Cursor-3.2.21-x86_64.AppImage";
    x86_64.hash = "sha256-1OtumCvJbLIoNflh1hrMz2at3k/FrqK+Qvhn/XGI2dU=";
    aarch64.url = "https://downloads.cursor.com/production/806df57ed3b6f1ee0175140d38039a38574ec722/linux/arm64/Cursor-3.2.21-aarch64.AppImage";
    aarch64.hash = "sha256-BEEZ4BkgDAJkM19TSMQQltJIiD0hsRXGP7BAHPZpHUc=";
  };
  src = fetchurl (
    if stdenv.hostPlatform.isx86_64
    then sources.x86_64
    else if stdenv.hostPlatform.isAarch64
    then sources.aarch64
    else throw "Unsupported architecture for Cursor"
  );
  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraInstallCommands = ''
    mkdir -p $out/share/icons
    (
      cd ${appimageContents}/usr
      for dir in share/icons/*/*/apps; do
        mkdir -p $out/$dir
        cp $dir/cursor.png $out/$dir/cursor.png || true
        cp $dir/cursor.png $out/$dir/co.anysphere.cursor.png || true
        cp $dir/cursor.svg $out/$dir/cursor.svg || true
        cp $dir/cursor.svg $out/$dir/co.anysphere.cursor.svg || true
      done
    )
    mkdir -p $out/share/applications
    cp -r ${appimageContents}/usr/share/applications $out/share/
    # Patch desktop file to use the correct executable
    sed -i 's|^Exec=/usr/share/cursor/cursor|Exec=cursor|' $out/share/applications/*.desktop
  '';
  meta = with lib; {
    description = "AI-first code editor built on VS Code";
    longDescription = ''
      Cursor is an AI-powered code editor that extends VS Code's functionality with advanced
      AI capabilities, such as AI-assisted code completion and refactoring, natural language
      command processing.
    '';
    homepage = "https://cursor.com";
    downloadPage = "https://cursor.com/download";
    changelog = "https://github.com/getcursor/cursor/releases";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ maintainers.kugland ];
    mainProgram = "cursor";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
