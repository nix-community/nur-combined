{
  pkgs,
  lib,
}: let
  pname = "cursor";
  version = "";
  sources = {
    x86_64.url = "https://downloads.cursor.com/production/4f2b772756b8f609e1354b3063de282ccbe7a69b/linux/x64/Cursor-2.4.27-x86_64.AppImage";
    x86_64.hash = "sha256-VAdpltgyfajmJdKKiEXIY6IzkJAg790LWZrONkEnkNc=";
    # Arm64 link is giving 403 for some reason
    #aarch64.url = "https://downloads.cursor.com/production/45fd70f3fe72037444ba35c9e51ce86a1977ac11/linux/arm64/Cursor-2.0.34-aarch64.AppImage";
    #aarch64.hash = "";
  };
  src = pkgs.fetchurl (
    if pkgs.stdenv.hostPlatform.isx86_64
    then sources.x86_64
    #else if pkgs.stdenv.hostPlatform.isAarch64
    #then sources.aarch64
    else throw "Unsupported architecture for Cursor"
  );
  appimageContents = pkgs.appimageTools.extract {inherit pname version src;};
in
  pkgs.appimageTools.wrapType2 {
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
      platforms = ["x86_64-linux"]; # "aarch64-linux" ];
      maintainers = [lib.maintainers.kugland];
      mainProgram = "cursor";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
