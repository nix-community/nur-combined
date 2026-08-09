{
  lib,
  stdenvNoCC,
  closureInfo,
  replaceVars,
  appimagetool,
  imagemagick_light,
}:
lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;

  excludeDrvArgNames = [
    "appName"
    "executable"
    "desktopFile"
    "iconPath"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      # The application to wrap
      # All store paths of the runtime
      # closure are added to the appimage.
      executable,
      # The name of the output appimage
      appName ? executable.pname,
      # Path to the desktop file. An item is required.
      # Can be set to `makeDesktopItem { }`.
      desktopFile ? null,
      # An icon is also required.
      # We attempt to detect one but it may require
      # a manually set icon.
      #
      # Must be equal to the `Icon=` key in the supplied Desktop file.
      iconPath ? null,
      pname ? appName + "-appimage",
      version ? executable.version,
      meta ? executable.meta or { },
    }:
    let
      execBin = lib.getBin executable;

      closure = closureInfo {
        rootPaths = [
          execBin
        ];
      };

      desktopFile' =
        if desktopFile == null then
          "${execBin}/share/applications/${executable.meta.mainProgram or executable.pname}.desktop"
        else
          desktopFile;

      appRun = replaceVars ./AppRun.template.sh {
        NIX_STORE = builtins.storeDir;
        EXECUTABLE_PATH = lib.getExe executable;
      };

      storePaths = "${closure}/store-paths";
    in
    {
      inherit pname version;

      strictDeps = true;
      __structuredAttrs = true;

      dontUnpack = true;
      dontFixup = true;

      nativeBuildInputs = [
        appimagetool
      ];

      iconPath = if iconPath == null then false else iconPath;

      buildPhase = ''
        mkdir AppDir

        mkdir -p "AppDir/$NIX_STORE"
        mkdir -p "AppDir/usr/bin"
        mkdir -p "AppDir/usr/share/applications"
        mkdir -p "AppDir/usr/share/icons/"

        cp -- "${appRun}" "AppDir/usr/bin"
        chmod +x -- "AppDir/usr/bin"/*

        cp -- "${desktopFile'}" "AppDir/usr/share/applications"

        mapfile -d "" -t iconDirs < <(find "${execBin}/share/icons/hicolor" -maxdepth 1 -mindepth 1 -type d -print0 | sort -Vrz)

        if [[ -n "$iconPath" ]]; then
          # Putting an icon within share/icons is valid according to freedesktop
          # so we will just plop our icons there rather than doing size detection
          cp -- "$iconPath" "AppDir/usr/share/icons"
        elif [[ "''${#iconDirs[@]}" -gt 0 ]]; then
          # Just glob whatever, there should only be a single file within an icon dir
          iconPath="''${iconDirs[0]}"/*
          cp -- "$iconPath" "AppDir/usr/share/icons"
        else
          echo "Unable to find icon. Please supply once with the 'iconPath' attribute"
          exit 1
        fi

        # Symlink eveything to their standard names
        # Needs exactly four file:
        # AppRun
        # *.desktop
        # .DirIcon
        # *.{svg, png}
        ln -s -- "AppDir/usr/bin/"* "AppDir/AppRun"
        ln -s -- "AppDir/usr/share/application/"* "AppDir/${appName}.desktop"

        if [[ "AppDir/usr/share/icons"* == *.svg ]]; then
          ln -s -- "AppDir/usr/share/icons/"* "AppDir/${appName}.svg"
          magick "AppDir/${appName}.svg" -resize 256x256 "AppDir/.DirIcon"
        else
          ln -s -- "AppDir/usr/share/icons/"* "AppDir/${appName}.png"
          ln -s -- "AppDir/usr/share/icons/"* "AppDir/.DirIcon"
        fi

        # Copy Nix Store paths
        readarray -t storePathsArray < "${storePaths}"
        cp -a -- "''${storePathsArray[@]}" "AppDir/$NIX_STORE"
      '';

      installPhase = ''
        mkdir -p "$out/bin"

        appimagetool -v AppDir "$out/bin/${appName}.appimage"
      '';

      meta = meta // {
        description = ''
          Appimage executable of ${appName}
        '';
      };
    };
}
