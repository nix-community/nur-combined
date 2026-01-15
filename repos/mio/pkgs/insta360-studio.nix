{
  lib,
  build,
  pkgs,
  wine,
  ...
}:
let
  inherit (pkgs) copyDesktopItems fetchurl makeDesktopItem;
  inherit (build) copyDesktopIcons makeDesktopIcon mkWindowsAppNoCC;
in
mkWindowsAppNoCC rec {
  inherit wine;
  pname = "insta360-studio";
  version = "5.8.8";
  src = fetchurl {
    url = "https://web.archive.org/web/20260114041411if_/https://wassets.insta360.com/common/788bedf7621f4bcd9c128fe9c4cc21ba/Insta360_Studio_5.8.8_release_insta360(RC_build53)_20260109_152003_1767943428406.exe";
    sha256 = "11x1c06kygqm6x2plxbqpkicadyrmffvrrqrg4l8qfcga3cmimxz";
    name = "insta360-studio.exe";
  };

  dontUnpack = true;
  wineArch = "win64";

  fileMap = {
    "$HOME/.config/Insta360/Local" = "drive_c/users/$USER/AppData/Local/Insta360";
  };

  enableMonoBootPrompt = false;
  nativeBuildInputs = [
    copyDesktopItems
    copyDesktopIcons
  ];

  winAppInstall = ''
    $WINE start /unix ${src} /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
    wineserver -w
    rm -f "$WINEPREFIX/drive_c/Program Files/Insta360 Studio/uninstall.exe"
    rm -fR "$WINEPREFIX/drive_c/Program Files/Insta360 Studio/updater"
  '';

  winAppRun = ''
    $WINE start /unix "$WINEPREFIX/drive_c/Program Files/Insta360 Studio/Insta360 Studio.exe" "$ARGS"
  '';

  installPhase = ''
    runHook preInstall
    ln -s $out/bin/.launcher $out/bin/${pname}
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Insta360 Studio";
      exec = pname;
      icon = pname;
      desktopName = "Insta360 Studio";
      genericName = "Video Editor";
      categories = [
        "AudioVideo"
        "Video"
        "AudioVideoEditing"
      ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = fetchurl {
      url = "https://web.archive.org/web/20260115031537if_/https://res.insta360.com/static/ab6ade0de352acdcf2d92cb49649a602/20240326-174927.jpeg";
      sha256 = "17cln3yd2gsybcq7dqi2saicp6zx7m6sxnjy6vpqz3x01kyami17";
    };
  };

  meta = with lib; {
    mainProgram = pname;
    homepage = "https://www.insta360.com/download/insta360-studio";
    description = "Video editing software for Insta360 cameras";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
