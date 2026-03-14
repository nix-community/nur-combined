{ lib
, stdenv
, fetchurl
, appimageTools
,
}:
let
  pname = "cursor";
  version = "2.6";
  sources = {
    x86_64.url = "https://api2.cursor.sh/updates/download/golden/linux-x64/${pname}/${version}";
    x86_64.hash = "sha256-5jiZJ6afm5+lNXkFejkCWHbeJkK9fDRIVA+YqB+tuyU=";
    aarch64.url = "https://api2.cursor.sh/updates/download/golden/linux-arm64/${pname}/${version}";
    aarch64.hash = "sha256-37T+25saAH8YwTJHJUUIddf9sEgHl2f9P5XLb+EfkAI=";
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
  meta = with lib;{
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
    maintainers = with maintainers; [ kugland ];
    mainProgram = "cursor";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
