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
  version = "5.9.9";
  # https://www.insta360.com/download
  src = fetchurl {
    url = "https://wassets.insta360.com/common/c78709860ff945ff9a2a0b16839bacb4/Insta360_Studio_5.9.9_release_insta360(RC_build1)_20260609_221201_1781014557100.exe";
    hash = "sha256-KPQknqIRK7e0ttj67dxkxmgkQBjBIHdINLiHX7ej2jg=";
    name = "insta360-studio-5.9.9.exe";
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
    winetricks --unattended cjkfonts >/dev/null 2>&1
  '';

  winAppRun = ''
    $WINE start /unix "$WINEPREFIX/drive_c/Program Files/Insta360 Studio/Insta360 Studio.exe" "$ARGS"
  '';

  installPhase = ''
    runHook preInstall
    mv $out/bin/.launcher $out/bin/${pname}
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
