{
  lib,
  pkgs,
  wineWow64Packages,
  # Named wineStaging (not `wine`) so callPackage does not inject pkgs.wine (32-bit).
  wineStaging ? wineWow64Packages.stagingFull,
  fetchurl,
  makeDesktopItem,
  copyDesktopItems,
  p7zip,
  gawk,
  xrandr,
  testers,
  # Virtual desktop mitigates black preview / transparent child-window overlays under Wine
  # (WineHQ Bronze report for 5.7; Reddit/CapNoeh guidance for 3.9).
  virtualDesktop ? true,
  # Default channel: CapCut 3.9 (CapNoeh / WineHQ Silver). Override for 5.x.
  pname ? "capcut",
  version ? "3.9.0.1459",
  installerName ? "CapCut_3_9_0_1459_capcutpc_0_creatortool.exe",
  installerUrls ? [
    "https://web.archive.org/web/20240623100008if_/https://lf16-capcut.faceulv.com/obj/capcutpc-packages-us/packages/CapCut_3_9_0_1459_capcutpc_0_creatortool.exe"
    "https://lf16-capcut.faceulv.com/obj/capcutpc-packages-us/packages/CapCut_3_9_0_1459_capcutpc_0_creatortool.exe"
  ],
  hash ? "sha256-f4wpuEM0t21KCvhnS2PHo8ZMw6A1Ga4OVS1bqqEVdV0=",
  # XDG config leaf under ~/.config (keep 3.9 / 5.x prefixes separate).
  configLeaf ? "capcut",
  desktopName ? "CapCut",
  downloadPage ? "https://appdb.winehq.org/objectManager.php?sClass=version&iId=42555",
  # Always block silent upgrade into CapCut 9.x (CEF zombie under Wine; CapNoeh).
  blockAutoUpdate ? true,
}:

# CapCut under Wine. Setup adapted from:
# - https://www.reddit.com/r/linux/comments/1mt3em7/running_capcut_on_linux_now_working_update/ (u/LinsaFTW)
# - https://github.com/Noehnoe/CapNoeh
# - https://github.com/smallmonk67-gif/Capcut-wineprefix
# - WineHQ AppDB 3.9: https://appdb.winehq.org/objectManager.php?sClass=version&iId=42555
# - WineHQ AppDB 5.7: https://appdb.winehq.org/objectManager.php?sClass=version&iId=42553
# - Official installer index: https://gist.github.com/HungHT1890/5b325526eca01011a1d8bd929c7dffbb
let
  myLib = import ../../../lib { inherit pkgs; };
  inherit (myLib) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
  wine = wineStaging;

  src = fetchurl {
    name = installerName;
    urls = installerUrls;
    inherit hash;
  };

  # Extract JYPacket once into the Nix store (avoids a large copy through unionfs).
  capcutApp = pkgs.stdenvNoCC.mkDerivation {
    pname = "${pname}-app";
    inherit version src;
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
  globalSettingFile = pkgs.writeText "${pname}-globalSetting" (
    lib.concatStringsSep "\r\n" (
      [
        "[General]"
      ]
      ++ lib.optionals blockAutoUpdate [
        "enableAutoUpdate=false"
        "totalSilentUpgradeSwitch=false"
        "localTestSilentUpdateSwtich=false"
        "debugSilentUpgradeSwitch=false"
      ]
      ++ [
        "user_license_agreed=true"
        "privacy_policy_update_time=9999999999"
        ""
      ]
    )
  );

  icon = pkgs.stdenvNoCC.mkDerivation {
    name = "${pname}-logo";
    nativeBuildInputs = [ p7zip ];
    dontUnpack = true;
    src = capcutApp;
    installPhase = ''
      mkdir -p $out
      # Versioned Resources path differs slightly across CapCut channels.
      if [ -f ${capcutApp}/${version}/Resources/logo_cc.png ]; then
        cp ${capcutApp}/${version}/Resources/logo_cc.png $out/icon.png
      else
        logo=$(find ${capcutApp} -type f -name 'logo_cc.png' | head -n1)
        cp "$logo" $out/icon.png
      fi
    '';
  };

  package = mkWindowsAppNoCC rec {
    inherit
      wine
      pname
      version
      src
      ;

    dontUnpack = true;
    # App binary is PE32+; payload is extracted at build time (skip PE32 GUI installer).
    wineArch = "win64";
    persistRegistry = true;
    persistRuntimeLayer = true;
    enableMonoBootPrompt = false;
    # WineHQ 5.7: DXVK/Vulkan backend crashes CapCut — stay on Wine's default GL path.
    enableVulkan = false;
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
      "$HOME/.config/${configLeaf}" = "drive_c/users/$USER/AppData/Local/CapCut/User Data";
    };

    winAppInstall = ''
      export WINEDEBUG="-all"

      # WineHQ / CapNoeh: installer needs these dirs before first run.
      capcut_root="$WINEPREFIX/drive_c/users/$USER/AppData/Local/CapCut"
      mkdir -p "$capcut_root/Apps" "$capcut_root/User Data/Config" "$capcut_root/User Data/Log"

      ${lib.optionalString blockAutoUpdate ''
        # Block auto-update into broken CapCut 9.x before first launch (CapNoeh).
        cp ${globalSettingFile} "$capcut_root/User Data/Config/globalSetting"
      ''}

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

    winAppPreRun = lib.optionalString blockAutoUpdate ''
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
        inherit desktopName;
        genericName = "Video Editor";
        categories = [
          "AudioVideo"
          "Video"
          "AudioVideoEditing"
        ];
        comment =
          if blockAutoUpdate then
            "${desktopName} ${version} (Wine) — pinned; auto-update blocked"
          else
            "${desktopName} ${version} (Wine)";
      })
    ];

    desktopIcon = makeDesktopIcon {
      name = pname;
      src = "${icon}/icon.png";
    };

    meta = with lib; {
      description = "CapCut video editor ${version} (Wine${lib.optionalString blockAutoUpdate "; auto-update blocked"})";
      longDescription = ''
        Packages CapCut ${version} under wine-staging.

        - extracts the installer payload (JYPacket) into the Nix store
        - pre-creates CapCut AppData directories (WineHQ / CapNoeh installer workaround)
        ${lib.optionalString blockAutoUpdate "- seeds globalSetting to disable auto-update into CapCut 9.x (CEF zombie under Wine)\n"}
        - defaults to a Wine virtual desktop (mitigates black preview overlay; WineHQ 5.7 / Reddit 3.9)
        - keeps enableVulkan=false (WineHQ: DXVK crashes CapCut 5.7)

        CapCut 3.9 is the CapNoeh-recommended default. CapCut 5.7 is WineHQ Bronze
        (editing/export work; preview transparency/black overlay remains). CapCut 9.x
        is not packaged here.

        Credits / references:
        - u/LinsaFTW — https://www.reddit.com/r/linux/comments/1mt3em7/running_capcut_on_linux_now_working_update/
        - CapNoeh — https://github.com/Noehnoe/CapNoeh
        - Capcut-wineprefix — https://github.com/smallmonk67-gif/Capcut-wineprefix
        - WineHQ AppDB — ${downloadPage}
        - Installer index — https://gist.github.com/HungHT1890/5b325526eca01011a1d8bd929c7dffbb

        CapCut is proprietary software by ByteDance; this package is not affiliated
        with or endorsed by ByteDance.
      '';
      homepage = "https://www.capcut.com/";
      inherit downloadPage;
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
      mainProgram = pname;
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
