{
  lib,
  build,
  pkgs,
  wine,
  ...
}:
# https://github.com/microsoft/winget-pkgs/blob/master/manifests/c/Canva/Affinity/3.0.2.3912/Canva.Affinity.installer.yaml
# https://github.com/ryzendew/Linux-Affinity-Installer/blob/main/AffinityScripts/Affinityv3.sh
let
  inherit (pkgs)
    copyDesktopItems
    fetchurl
    makeDesktopItem
    p7zip
    unzip
    wget
    zstd
    ;
  inherit (build) copyDesktopIcons makeDesktopIcon mkWindowsAppNoCC;
in
mkWindowsAppNoCC rec {
  inherit wine;

  pname = "affinity-v3";
  version = "3.0.2.3912";

  # Official MSIX installer from winget manifest
  src = fetchurl {
    url = "https://affinity-update.serif.com/windows/3/studio/retail/Affinity-Affinity-Store-x64-3912-4bf44c776b9fb8dc4ea7f01eedebcde34012ba83.msix";
    sha256 = "84d97a3e24f6c8048ff4cba00c4820883133359c4161129dba1975527f0c0428";
    name = "affinity-v3.msix";
  };

  dontUnpack = true;
  wineArch = "win64";
  persistRegistry = false;
  persistRuntimeLayer = true;
  enableMonoBootPrompt = false;
  graphicsDriver = "auto";
  enableVulkan = false; # Using vkd3d-proton instead for better compatibility

  nativeBuildInputs = [
    copyDesktopItems
    copyDesktopIcons
    p7zip
    unzip
    wget
    zstd
  ];

  enabledWineSymlinks = {
    desktop = false;
  };

  fileMap = {
    "$HOME/.config/affinity-v3/Local" = "drive_c/users/$USER/AppData/Local/Affinity";
    "$HOME/.config/affinity-v3/Roaming" = "drive_c/users/$USER/AppData/Roaming/Affinity";
  };

  winAppInstall = ''
    export WINEDEBUG="-all"
    work="$(mktemp -d)"

    echo "Extracting MSIX package (ZIP format)..."
    ${unzip}/bin/unzip -q ${src} -d "$work/msix" || {
      echo "Error: Failed to extract MSIX package" >&2
      rm -rf "$work"
      exit 1
    }

    echo "Installing Windows dependencies..."
    winetricks --unattended dotnet35
    winetricks --unattended dotnet48
    winetricks --unattended vcrun2022
    winetricks --unattended corefonts
    winetricks --unattended msxml3
    winetricks --unattended msxml6
    winetricks --unattended tahoma
    winetricks --unattended win11
    winetricks renderer=vulkan

    echo "Installing Windows metadata..."
    winmetadata_dir="$WINEPREFIX/drive_c/windows/system32/WinMetadata"
    mkdir -p "$winmetadata_dir"
    winmetadata_zip="$work/WinMetadata.zip"
    ${wget}/bin/wget -q "https://archive.org/download/win-metadata/WinMetadata.zip" -O "$winmetadata_zip"
    ${unzip}/bin/unzip -q -o "$winmetadata_zip" -d "$winmetadata_dir"

    echo "Installing vkd3d-proton for OpenCL/hardware acceleration..."
    vkd3d_url="https://github.com/HansKristian-Work/vkd3d-proton/releases/download/v2.14.1/vkd3d-proton-2.14.1.tar.zst"
    vkd3d_archive="$work/vkd3d-proton-2.14.1.tar.zst"
    ${wget}/bin/wget -q "$vkd3d_url" -O "$vkd3d_archive"
    ${zstd}/bin/zstd -d "$vkd3d_archive" -o "$work/vkd3d-proton.tar"
    tar -xf "$work/vkd3d-proton.tar" -C "$work"
    
    vkd3d_dir=$(find "$work" -type d -name "vkd3d-proton-*" | head -1)
    if [ -n "$vkd3d_dir" ]; then
      wine_lib_dir="$WINEPREFIX/drive_c/windows/system32"
      mkdir -p "$wine_lib_dir"
      
      # Copy d3d12 DLLs
      if [ -f "$vkd3d_dir/x64/d3d12.dll" ]; then
        cp "$vkd3d_dir/x64/d3d12.dll" "$wine_lib_dir/"
      fi
      if [ -f "$vkd3d_dir/x64/d3d12core.dll" ]; then
        cp "$vkd3d_dir/x64/d3d12core.dll" "$wine_lib_dir/"
      fi
      
      echo "Configuring Wine DLL overrides for vkd3d-proton..."
      $WINE reg add "HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides" /v d3d12 /t REG_SZ /d native /f
      $WINE reg add "HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides" /v d3d12core /t REG_SZ /d native /f
    fi

    echo "Installing Affinity from MSIX..."
    affinity_dest="$WINEPREFIX/drive_c/Program Files/Affinity"
    mkdir -p "$affinity_dest"
    cp -r "$work/msix"/* "$affinity_dest/"

    # Find and verify Affinity.exe location
    affinity_exe=$(find "$affinity_dest" -name "Affinity.exe" -type f | head -1)
    if [ -z "$affinity_exe" ]; then
      echo "Error: Affinity.exe not found in extracted MSIX" >&2
      echo "Contents of $affinity_dest:" >&2
      ls -la "$affinity_dest" >&2 || true
      rm -rf "$work"
      exit 1
    fi

    echo "Found Affinity.exe at: $affinity_exe"
    rm -rf "$work"
    echo "Affinity v3 installation completed"
  '';

  winAppRun = ''
    export WINEDEBUG="-all"

    # Find Affinity.exe in the installation directory
    affinity_exe=$(find "$WINEPREFIX/drive_c/Program Files/Affinity" -name "Affinity.exe" -type f | head -1)

    if [ -z "$affinity_exe" ] || [ ! -f "$affinity_exe" ]; then
      echo "Error: Affinity v3 executable not found" >&2
      exit 1
    fi

    $WINE start /unix "$affinity_exe" "$ARGS"
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
      desktopName = "Affinity v3";
      genericName = "Creative Suite";
      comment = "Unified Affinity application with Photo, Designer, and Publisher";
      categories = [
        "Graphics"
        "Photography"
        "VectorGraphics"
        "RasterGraphics"
        "Publishing"
      ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = fetchurl {
      # Official Affinity v3 icon from the repository
      url = "https://github.com/seapear/AffinityOnLinux/raw/main/Assets/Icons/Affinity-Canva.svg";
      hash = "sha256-GgqO8yig9xXhYOmQVB3uweKvePshtN4JJIMNsT/Uoh0=";
    };
  };

  meta = with lib; {
    description = "Affinity v3 - Unified creative suite combining Photo, Designer, and Publisher (via Wine)";
    longDescription = ''
      Affinity v3 is the unified application that combines Affinity Photo,
      Affinity Designer, and Affinity Publisher into a single modern interface.

      This package runs Affinity v3 using Wine with hardware acceleration support.

      Note: You need a valid Affinity license to use this software.
      The installer needs to be downloaded from https://www.affinity.studio/
    '';
    homepage = "https://affinity.serif.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
    maintainers = [ ];
  };
}
