{
  lib,
  pkgs,
  wineWow64Packages,
  # Named wineStaging (not `wine`) so callPackage does not inject pkgs.wine (32-bit).
  wineStaging ? wineWow64Packages.stagingFull,
  requireFile,
  makeDesktopItem,
  copyDesktopItems,
  p7zip,
  gawk,
  xrandr,
  testers,
  # Virtual desktop avoids the black preview overlay reported under Wine.
  # See: https://www.reddit.com/r/linux/comments/1mt3em7/running_capcut_on_linux_now_working_update/
  virtualDesktop ? true,
}:

# CapCut 3.9.0.1459 under Wine. Newer CapCut 9.x leaves CrBrowserMain as a zombie
# under Wine (see CapNoeh). Setup adapted from:
# - https://www.reddit.com/r/linux/comments/1mt3em7/running_capcut_on_linux_now_working_update/ (u/LinsaFTW)
# - https://github.com/Noehnoe/CapNoeh
# - https://github.com/smallmonk67-gif/Capcut-wineprefix
# - https://appdb.winehq.org/objectManager.php?sClass=version&iId=42555
let
  myLib = import ../../../lib { inherit pkgs; };
  inherit (myLib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
  wine = wineStaging;

  installerName = "CapCut_3_9_0_1459_capcutpc_0_creatortool.exe";

  # CapNoeh expected size/sha256 for 3.9.0.1459.
  src = requireFile {
    name = installerName;
    hash = "sha256-f4wpuEM0t21KCvhnS2PHo8ZMw6A1Ga4OVS1bqqEVdV0=";
    message = ''
      CapCut is proprietary and ByteDance no longer publishes 3.9.0.1459.

      Obtain CapCut_3_9_0_1459_capcutpc_0_creatortool.exe (525 MiB) yourself and verify:

        size    550534120
        sha256  7f8c29b84334b76d4a0af8674b63c7a3c64cc3a03519ae0e552d5baaa115755d

      Possible sources (not redistributed here):
        - WineHQ AppDB: https://appdb.winehq.org/objectManager.php?sClass=version&iId=42555
        - Wayback: https://web.archive.org/web/20240623100008id_/https://lf16-capcut.faceulv.com/obj/capcutpc-packages-us/packages/CapCut_3_9_0_1459_capcutpc_0_creatortool.exe
        - CapNoeh docs: https://github.com/Noehnoe/CapNoeh

      Then add it to the Nix store:

        nix-store --add-fixed sha256 ${installerName}
        # or: nix-prefetch-url file://$PWD/${installerName}
    '';
  };

  # Extract JYPacket once into the Nix store (avoids a 1.3 GiB copy through unionfs).
  capcutApp = pkgs.stdenvNoCC.mkDerivation {
    pname = "capcut-app";
    version = "3.9.0.1459";
    inherit src;
    nativeBuildInputs = [ p7zip ];
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      mkdir -p work "$out"
      ${p7zip}/bin/7z x -y -o"$PWD/work" ${src}
      cp -a work/JYPacket/. "$out/"
      runHook postInstall
    '';
  };

  # CRLF INI as CapNoeh seeds it (QSettings).
  globalSettingFile = pkgs.writeText "capcut-globalSetting" (
    lib.concatStringsSep "\r\n" [
      "[General]"
      "enableAutoUpdate=false"
      "totalSilentUpgradeSwitch=false"
      "localTestSilentUpdateSwtich=false"
      "debugSilentUpgradeSwitch=false"
      "user_license_agreed=true"
      "privacy_policy_update_time=9999999999"
      ""
    ]
  );

  icon = pkgs.stdenvNoCC.mkDerivation {
    name = "capcut-logo";
    nativeBuildInputs = [ p7zip ];
    dontUnpack = true;
    # Prefer the already-extracted tree when available.
    src = capcutApp;
    installPhase = ''
      mkdir -p $out
      cp ${capcutApp}/3.9.0.1459/Resources/logo_cc.png $out/icon.png
    '';
  };
  package = mkWindowsAppNoCC rec {
    inherit wine;

    pname = "capcut";
    version = "3.9.0.1459";

    inherit src;
    dontUnpack = true;
    # App binary is PE32+; payload is extracted at build time (skip PE32 GUI installer).
    wineArch = "win64";
    persistRegistry = true;
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

    # Persist projects/settings; Apps/ is copied into the install layer (writable).
    fileMap = {
      "$HOME/.config/capcut" = "drive_c/users/$USER/AppData/Local/CapCut/User Data";
    };

    winAppInstall = ''
      export WINEDEBUG="-all"

      capcut_root="$WINEPREFIX/drive_c/users/$USER/AppData/Local/CapCut"
      mkdir -p "$capcut_root/Apps" "$capcut_root/User Data/Config" "$capcut_root/User Data/Log"

      # Block auto-update into broken 9.x before first launch (CapNoeh).
      cp ${globalSettingFile} "$capcut_root/User Data/Config/globalSetting"

      # Places bar so the Wine file dialog is usable (CapNoeh).
      places='HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Comdlg32\Placesbar'
      $WINE reg add "$places" /v Place0 /t REG_SZ /d "C:\\users\\$USER\\Downloads" /f
      $WINE reg add "$places" /v Place1 /t REG_SZ /d "C:\\users\\$USER\\Videos" /f
      $WINE reg add "$places" /v Place2 /t REG_SZ /d "C:\\users\\$USER\\Pictures" /f
      $WINE reg add "$places" /v Place3 /t REG_SZ /d "C:\\users\\$USER" /f
      $WINE reg add "$places" /v Place4 /t REG_DWORD /d 17 /f
      wineserver -w

      # Copy extracted JYPacket into a writable Apps tree (CapCut needs write access).
      # Nix store files are mode 444; VESafeGuard/etc. abort if the tree is read-only.
      cp -a --no-preserve=mode ${capcutApp}/. "$capcut_root/Apps/"
      chmod -R u+rwX "$capcut_root/Apps"

      if [ ! -f "$capcut_root/Apps/${version}/CapCut.exe" ]; then
        echo "CapCut installation failed: CapCut.exe missing under $capcut_root/Apps/${version}" >&2
        exit 1
      fi
    '';

    winAppPreRun = ''
      capcut_root="$WINEPREFIX/drive_c/users/$USER/AppData/Local/CapCut"
      cfg="$capcut_root/User Data/Config"
      mkdir -p "$cfg" "$capcut_root/User Data/Log"
      if [ ! -f "$cfg/globalSetting" ] || ! grep -q '^enableAutoUpdate=false' "$cfg/globalSetting"; then
        cp ${globalSettingFile} "$cfg/globalSetting"
      fi
    '';

    winAppRun = ''
      export WINEDEBUG="-all"
      # Prefer the PE32+ app binary (versioned dir); PE32 CapCut.exe is only a launcher.
      exe="$WINEPREFIX/drive_c/users/$USER/AppData/Local/CapCut/Apps/${version}/CapCut.exe"
      if [ ! -f "$exe" ]; then
        exe="$WINEPREFIX/drive_c/users/$USER/AppData/Local/CapCut/Apps/CapCut.exe"
      fi
      if [ ! -f "$exe" ]; then
        echo "CapCut executable not found in Wine prefix" >&2
        exit 1
      fi

      if ${
        if virtualDesktop then "true" else "false"
      } && [ "''${CAPCUT_NO_VIRTUAL_DESKTOP:-0}" != "1" ]; then
        res="$(${xrandr}/bin/xrandr 2>/dev/null | ${gawk}/bin/awk '/\*/ && $1 ~ /^[0-9]+x[0-9]+$/ {print $1; exit}')"
        if [ -z "$res" ]; then
          res="1920x1080"
        fi
        $WINE explorer /desktop=CapCut,"$res" "$exe" "''${ARGS[@]}"
      else
        $WINE "$exe" "''${ARGS[@]}"
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
        exec = pname;
        icon = pname;
        desktopName = "CapCut";
        genericName = "Video Editor";
        categories = [
          "AudioVideo"
          "Video"
          "AudioVideoEditing"
        ];
        comment = "CapCut 3.9 (Wine) — pinned build; auto-update blocked";
      })
    ];

    desktopIcon = makeDesktopIcon {
      name = pname;
      src = "${icon}/icon.png";
    };

    meta = with lib; {
      description = "CapCut video editor 3.9.0.1459 (Wine; auto-update blocked)";
      longDescription = ''
        Packages CapCut 3.9.0.1459 under wine-staging. Newer CapCut 9.x is known to
        crash under Wine (main CEF process becomes a zombie). This package:

        - extracts the installer payload (JYPacket) into the Nix store
        - pre-creates CapCut AppData directories (Reddit/CapNoeh installer workaround)
        - seeds globalSetting to disable auto-update into 9.x
        - defaults to a Wine virtual desktop (mitigates black preview overlay)

        Based on community work (please credit the originals):
        - u/LinsaFTW — https://www.reddit.com/r/linux/comments/1mt3em7/running_capcut_on_linux_now_working_update/
        - CapNoeh — https://github.com/Noehnoe/CapNoeh
        - Capcut-wineprefix — https://github.com/smallmonk67-gif/Capcut-wineprefix
        - WineHQ AppDB — https://appdb.winehq.org/objectManager.php?sClass=version&iId=42555

        CapCut is proprietary software by ByteDance; this package is not affiliated
        with or endorsed by ByteDance.
      '';
      homepage = "https://www.capcut.com/";
      downloadPage = "https://appdb.winehq.org/objectManager.php?sClass=version&iId=42555";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
      mainProgram = "capcut";
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
    };

    passthru.tests.nixos = testers.runNixOSTest (
      import ./test.nix {
        capcut = package;
        nixpkgsPath = pkgs.path;
      }
    );
  };
in
package
