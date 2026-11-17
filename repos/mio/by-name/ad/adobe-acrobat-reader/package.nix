{
  lib,
  pkgs,
  wineWow64Packages,
  # Named wineFull (not `wine`) so callPackage does not inject pkgs.wine (32-bit).
  wineFull ? wineWow64Packages.full,
  fetchurl,
  makeDesktopItem,
  copyDesktopItems,
  _7zz,
  gawk,
  xrandr,
  icoutils,
  testers,
  # AUR launcher defaults virtual desktop on (tab bar rendering).
  virtualDesktop ? true,
}:

# Synced with AUR acroread-dc-wine 26.002.22031-2 (maintainer Smoolak).
# https://aur.archlinux.org/packages/acroread-dc-wine
let
  myLib = import ../../../lib { inherit pkgs; };
  inherit (myLib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
  wine = wineFull;

  installerName = "AcroRdrDCx642600222031_en_US.exe";
  pkgverNodots = "2600222031";

  src = fetchurl {
    name = installerName;
    urls = [
      "https://web.archive.org/web/20261018223457if_/https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/${pkgverNodots}/${installerName}"
      "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/${pkgverNodots}/${installerName}"
    ];
    # AUR sha256sums; live Adobe CDN may re-sign and break 7z headers — prefer Wayback.
    hash = "sha256-humP6z8q+mZlaoXLvG+3HWoyF+v4/cIfTRpU0hy0UCg=";
  };

  mspatcha = pkgs.callPackage ./mspatcha.nix { };

  regTweaks = ./acroread-dc.reg;

  # Extract 256px icon from the installer SFX (AUR: wrestool/icotool).
  desktopIconSrc =
    pkgs.runCommand "adobe-acrobat-reader-icon"
      {
        nativeBuildInputs = [ icoutils ];
        inherit src;
      }
      ''
        mkdir icon
        wrestool -x -t14 -n128 -o icon/AcroRead.ico ${src}
        icotool -x icon/AcroRead.ico -o icon/
        install -Dm644 icon/*256x256*.png $out
      '';

  package = mkWindowsAppNoCC rec {
    inherit wine;

    pname = "adobe-acrobat-reader";
    version = "26.002.22031";

    inherit src;
    dontUnpack = true;
    wineArch = "win64";
    persistRegistry = false;
    persistRuntimeLayer = true;
    enableMonoBootPrompt = false;
    graphicsDriver = "auto";

    nativeBuildInputs = [
      copyDesktopItems
      copyDesktopIcons
    ];

    enabledWineSymlinks = {
      desktop = false;
    };

    fileMap = {
      "$HOME/.config/adobe-acrobat-reader/Local" = "drive_c/users/$USER/AppData/Local/Adobe";
      "$HOME/.config/adobe-acrobat-reader/LocalLow" = "drive_c/users/$USER/AppData/LocalLow/Adobe";
      "$HOME/.config/adobe-acrobat-reader/Roaming" = "drive_c/users/$USER/AppData/Roaming/Adobe";
    };

    winAppInstall = ''
      export WINEDEBUG="-all"
      export WINEDLLOVERRIDES="mspatcha=n,b;$WINEDLLOVERRIDES"

      winetricks --unattended win10
      winetricks --unattended riched20
      winetricks --unattended vcrun2015

      # Wine's built-in mspatcha cannot decode every PA19 stream used by current
      # Adobe updates (AUR). Install the source-built multi-arch implementation.
      install -m644 ${mspatcha}/lib/mspatcha-x64.dll \
        "$WINEPREFIX/drive_c/windows/system32/mspatcha.dll"
      install -m644 ${mspatcha}/lib/mspatcha-x86.dll \
        "$WINEPREFIX/drive_c/windows/syswow64/mspatcha.dll"

      work="$(mktemp -d)"
      ${_7zz}/bin/7zz x -t# -y ${src} -o"$work/compound" >/dev/null
      ${_7zz}/bin/7zz x -y "$work/compound/2.7z" -o"$work/extract" >/dev/null

      MSI="$work/extract/AcroPro.msi"
      MSP="$(find "$work/extract" -maxdepth 1 -type f -name 'AcroRdrDCx64Upd*.msp' -print -quit)"
      if [ ! -f "$MSI" ] || [ -z "$MSP" ]; then
        echo "AcroPro.msi or update MSP missing after 7zz extract" >&2
        ls -la "$work/extract" >&2 || true
        exit 1
      fi

      # Map extract dir to a free Wine drive letter (AUR setup script).
      DRIVE_LETTER=""
      for candidate in s r q p o n; do
        candidate_link="$WINEPREFIX/dosdevices/''${candidate}:"
        if [ ! -e "$candidate_link" ] && [ ! -L "$candidate_link" ]; then
          ln -s "$work/extract" "$candidate_link"
          DRIVE_LETTER="$candidate"
          break
        fi
      done
      if [ -z "$DRIVE_LETTER" ]; then
        echo "No free Wine drive letter for Acrobat install" >&2
        exit 1
      fi
      WINDOWS_DRIVE="$(echo "$DRIVE_LETTER" | tr '[:lower:]' '[:upper:]'):"
      MSP_BASENAME="$(basename "$MSP")"

      if ! $WINE msiexec \
        /i "''${WINDOWS_DRIVE}\\AcroPro.msi" \
        /qn '/l*v' 'C:\acroread-dc-install.log' \
        "PATCH=''${WINDOWS_DRIVE}\\''${MSP_BASENAME}" \
        EULA_ACCEPT=YES \
        SUPPRESS_APP_LAUNCH=YES \
        DISABLE_BROWSER_INTEGRATION=YES \
        INSTALLPDFPRINTER=0 \
        DISABLEDESKTOPSHORTCUT=1; then
        echo "Adobe Reader msiexec failed; see C:\\acroread-dc-install.log" >&2
        exit 1
      fi

      # Stop updater services started by the installer; do not wineserver -k.
      for service in armsvc edgeupdate edgeupdatem; do
        $WINE sc stop "$service" >/dev/null 2>&1 || true
      done

      rm -f "$WINEPREFIX/dosdevices/''${DRIVE_LETTER}:"
      rm -rf "$work"

      regfile="$WINEPREFIX/drive_c/acroread-dc.reg"
      cp ${regTweaks} "$regfile"
      $WINE regedit "$($WINE winepath -w "$regfile")" || true

      # Disable ARM / collab / CEF updater binaries (AUR).
      for PROG_FILES in \
        "$WINEPREFIX/drive_c/Program Files (x86)" \
        "$WINEPREFIX/drive_c/Program Files"; do
        COMMON_FILES="$PROG_FILES/Common Files/Adobe/ARM/1.0"
        if [ -d "$COMMON_FILES" ]; then
          for f in armsvc.exe AdobeARM.exe AdobeARMHelper.exe; do
            if [ -f "$COMMON_FILES/$f" ]; then
              mv "$COMMON_FILES/$f" "$COMMON_FILES/''${f}_disabled" 2>/dev/null || true
            fi
          done
        fi
        for READER_DIR in \
          "$PROG_FILES/Adobe/Acrobat DC/Acrobat" \
          "$PROG_FILES/Adobe/Acrobat Reader DC/Reader"; do
          [ -d "$READER_DIR" ] || continue
          if [ -f "$READER_DIR/AdobeCollabSync.exe" ]; then
            mv "$READER_DIR/AdobeCollabSync.exe" \
              "$READER_DIR/AdobeCollabSync.exe_disabled" 2>/dev/null || true
          fi
          if [ -f "$READER_DIR/AcroCEF/RdrServicesUpdater.exe" ]; then
            mv "$READER_DIR/AcroCEF/RdrServicesUpdater.exe" \
              "$READER_DIR/AcroCEF/RdrServicesUpdater.exe_disabled" 2>/dev/null || true
          fi
        done
      done

      $WINE reg add "HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\AeDebug" /v Debugger /t REG_SZ /d "" /f 2>/dev/null || true
      $WINE reg add "HKEY_LOCAL_MACHINE\\Software\\Wow6432Node\\Microsoft\\Windows NT\\CurrentVersion\\AeDebug" /v Debugger /t REG_SZ /d "" /f 2>/dev/null || true
      $WINE reg add "HKEY_CURRENT_USER\\Software\\Adobe\\Adobe Acrobat\\DC\\AVGeneral" /v bMaximizeAtOpen /t REG_DWORD /d 1 /f 2>/dev/null || true

      READER_EXE="$WINEPREFIX/drive_c/Program Files/Adobe/Acrobat DC/Acrobat/Acrobat.exe"
      if [ ! -f "$READER_EXE" ]; then
        echo "Acrobat.exe was not installed at the expected 64-bit path" >&2
        exit 1
      fi
    '';

    winAppRun = ''
      export WINEDEBUG="-all"
      export WINEDLLOVERRIDES="mspatcha=n,b;$WINEDLLOVERRIDES"

      reader=""
      for candidate in \
        "$WINEPREFIX/drive_c/Program Files/Adobe/Acrobat DC/Acrobat/Acrobat.exe" \
        "$WINEPREFIX/drive_c/Program Files (x86)/Adobe/Acrobat Reader DC/Reader/AcroRd32.exe" \
        "$WINEPREFIX/drive_c/Program Files/Adobe/Acrobat Reader DC/Reader/AcroRd32.exe"; do
        if [ -f "$candidate" ]; then
          reader="$candidate"
          break
        fi
      done
      if [ -z "$reader" ]; then
        echo "Adobe Acrobat Reader executable not found in Wine prefix" >&2
        exit 1
      fi

      # Convert existing file args to Wine paths (AUR launcher).
      RUN_ARGS=()
      for arg in "''${ARGS[@]}"; do
        if [ -e "$arg" ]; then
          abs_path="$(realpath "$arg")"
          win_path="$($WINE winepath -w "$abs_path" 2>/dev/null || true)"
          if [ -n "$win_path" ]; then
            win_path="''${win_path//\\//}"
            RUN_ARGS+=("$win_path")
          else
            RUN_ARGS+=("$arg")
          fi
        else
          RUN_ARGS+=("$arg")
        fi
      done

      if ${
        if virtualDesktop then "true" else "false"
      } && [ "''${ACROREAD_NO_VIRTUAL_DESKTOP:-0}" != "1" ]; then
        res="$(${xrandr}/bin/xrandr 2>/dev/null | ${gawk}/bin/awk '/\\*/ && $1 ~ /^[0-9]+x[0-9]+$/ {print $1; exit}')"
        if [ -z "$res" ]; then
          res="1920x1080"
        fi
        $WINE explorer /desktop=AcroRead,"$res" "$reader" "''${RUN_ARGS[@]}"
      else
        $WINE reg add "HKCU\Software\Wine\X11 Driver" /v Decorated /t REG_SZ /d N /f
        $WINE "$reader" "''${RUN_ARGS[@]}"
      fi
    '';

    installPhase = ''
      runHook preInstall

      mv $out/bin/.launcher $out/bin/${pname}

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = pname;
        exec = "${pname} %f";
        icon = pname;
        desktopName = "Adobe Acrobat Reader DC";
        genericName = "PDF Viewer";
        comment = "View and print PDF documents";
        categories = [
          "Office"
          "Viewer"
        ];
        mimeTypes = [
          "application/pdf"
          "application/vnd.fdf"
          "application/vnd.adobe.xfdf"
          "application/vnd.adobe.pdx"
          "application/vnd.adobe.xdp+xml"
        ];
        startupNotify = true;
        startupWMClass = "Acrobat.exe";
      })
    ];

    desktopIcon = makeDesktopIcon {
      name = pname;
      src = desktopIconSrc;
    };

    meta = with lib; {
      description = "Adobe Acrobat Reader DC - PDF viewer (via Wine)";
      homepage = "https://www.adobe.com/products/reader.html";
      downloadPage = "https://aur.archlinux.org/packages/acroread-dc-wine";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
      mainProgram = "adobe-acrobat-reader";
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
      longDescription = ''
        Packaging synced with AUR acroread-dc-wine ${version}-2:
        64-bit Acrobat DC installer, msiexec + MSP, patched Wine mspatcha,
        and virtual-desktop launch (tabs). Live Adobe CDN builds may re-sign
        the EXE and break 7-Zip extraction; the Wayback snapshot matching the
        AUR hash is preferred.
      '';
    };

    passthru = {
      inherit mspatcha;
      tests.nixos = testers.runNixOSTest (
        import ./test.nix {
          adobe-acrobat-reader = package;
          nixpkgsPath = pkgs.path;
        }
      );
    };
  };
in
package
