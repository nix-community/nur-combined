{ pkgs
, lib
,
}:
let
  sources = {
    x86_64.url = "https://downloads.cursor.com/production/5b19bac7a947f54e4caa3eb7e4c5fbf832389853/linux/x64/Cursor-1.1.6-x86_64.AppImage";
    x86_64.hash = "sha256-T0vJRs14tTfT2kqnrQWPFXVCIcULPIud1JEfzjqcEIM=";
    aarch64.url = "https://downloads.cursor.com/production/5b19bac7a947f54e4caa3eb7e4c5fbf832389853/linux/arm64/Cursor-1.1.6-aarch64.AppImage";
    aarch64.hash = "sha256-HKr87IOzSNYWIYBxVOef1758f+id/t44YM5+SNunkTs=";
  };
in
pkgs.appimageTools.wrapType2 {
  pname = "cursor";
  version = "1.1.6";
  src =
    pkgs.fetchurl
      (
        if pkgs.stdenv.isx86_64
        then sources.x86_64
        else if pkgs.stdenv.isAarch64
        then sources.aarch64
        else "Unsupported architecture for Cursor editor"
      );
  meta = {
    description = "AI-first code editor built on VS Code, designed to enhance productivity through AI-assisted coding";
    longDescription = ''
      Cursor is an AI-powered code editor that extends VS Code's functionality with advanced AI capabilities,
      such as AI-assisted code completion and refactoring, natural language command processing.
    '';
    homepage = "https://cursor.com";
    downloadPage = "https://cursor.com/download";
    changelog = "https://github.com/getcursor/cursor/releases";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = [ lib.maintainers.kugland ];
    mainProgram = "cursor";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
