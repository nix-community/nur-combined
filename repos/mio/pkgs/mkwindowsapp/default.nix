# mio patch: DPI
# Based on code from: https://raw.githubusercontent.com/lucasew/nixcfg/fd523e15ccd7ec2fd86a3c9bc4611b78f4e51608/packages/wrapWine.nix
{
  stdenv,
  lib,
  makeBinPath,
  writeShellScript,
  winetricks,
  cabextract,
  gnused,
  unionfs-fuse,
  libnotify,
  dxvk,
  mangohud,
  util-linux,
  coreutils,
  writeScript,
  rsync,
  systemd,
  pkgs,
}:
{
  wine,
  wineArch ? "win32",
  winAppRun,
  winAppPreRun ? "",
  winAppPostRun ? "",
  winAppInstall ? "",
  buildInputs ? [ ], # List of Nix packages (containing executables) to add to $PATH
  name ? "${attrs.pname}-${attrs.version}",
  enableInstallNotification ? true,
  fileMap ? { },
  fileMapDuringAppInstall ? false,
  persistRegistry ? false, # Disabled by default because it hurts reproduceability.
  persistRuntimeLayer ? false,
  enableVulkan ? false, # Determines the DirectX rendering backend. Defaults to opengl.
  dxvkOptions ? { }, # Determines the DXVK installation options when using `enableVulkan`. See `dxvkDefaultOptions`.
  rendererOverride ? null, # Can be wine-opengl, wine-vulkan, or dxvk-vulkan. Used to override renderer selection. Avoid using.
  enableHUD ? false, # When enabled, use $MANGOHUD as the mangohud command.

  # The method used to calculate the input hashes for the layers.
  # This should be set to "store-path", which is the strictest and most reproduceable method. But it results in many rebuilds of the layers.
  # An alternative is "version" which is a relaxed method and results in fewer rebuilds but is less reproduceable.
  inputHashMethod ? "store-path",

  # Wine creates a number of symlinks in the Windows user profile directory.
  # This attribute set allows specific symlinks to be disabled.
  # For example, if you find that an application creates a Windows shortcut in your Linux home directory,
  # the Desktop symlink can be disabled with { desktop = false; }.
  # When a symlink is disabled, it's replaced with a directory. That way anything written to it remains in a mkWindowsApp layer.
  # Acceptable attributes, all of which default to the boolean value 'true', are:
  # desktop, documents, downloads, music, pictures, and videos.
  enabledWineSymlinks ? { },

  # By default, when a Wine prefix is first created Wine will produce a warning prompt if Mono is not installed.
  # This doesn't happen with the Wine "full" packages, but it does happen with the "base" packages.
  # When this option is set to 'false', DLL overrides are used when the Wine prefix is created, to bypass the prompt.
  enableMonoBootPrompt ? true,

  # Starting with version 10, Wine uses Wayland if it's available. But, usually Wayland compositors enable xwayland,
  # which causes Wine to default to X11.
  # When `graphicsDriver` is set to "auto", Wine is allowed to determine whether to use Wayland or X11.
  # When set to "wayland", DISPLAY is unset prior to running Wine, causing it to use Wayland.
  # When set to "prefer-wayland", DISPLAY is unset only if WAYLAND_DISPLAY is set, causing Wine to use Wayland only when Wayland is available.
  graphicsDriver ? "auto",

  # When set to true, the launcher script will obtain an idle inhibit lock when executing the Windows app.
  # An idle inhibit lock can prevent the screen from turning off. Thus, this is most useful for Windows games.
  inhibitIdle ? false,
  ...
}@attrs:
let
  api = "1"; # IMPORTANT: Make sure this corresponds with WA_API in libwindowsapp.bash
  libwindowsapp = ./libwindowsapp.bash;

  # Wayland support, starting with Wine 10.

  graphicsDriverCmd =
    let
      requiresWine10 =
        cmd:
        if (lib.versionAtLeast wine.version "10") then
          cmd
        else
          abort "At least Wine 10 is required to use the wayland graphics driver.";
    in
    {
      "auto" = "";
      "wayland" = requiresWine10 "unset DISPLAY";
      "prefer-wayland" = requiresWine10 ''
        if [ -n "$WAYLAND_DISPLAY" ]
        then
            unset DISPLAY 
        fi
      '';
    }
    ."${graphicsDriver}";

  # OpenGL or Vulkan rendering support
  renderer =
    if rendererOverride != null then
      rendererOverride
    else
      (if !enableVulkan then "wine-opengl" else "dxvk-vulkan");

  setupRendererScript =
    let
      setWineRenderer = value: ''
        $WINE reg add 'HKCU\Software\Wine\Direct3D' /v renderer /d "${value}" /f
      '';

      dxvkDefaultOptions = {
        enableDXGI = true;
        enableD3D10 = false;
      };

      dxvkAppliedOptions = dxvkDefaultOptions // dxvkOptions;
    in
    {
      wine-opengl = setWineRenderer "gl";
      wine-vulkan = setWineRenderer "vulkan";
      dxvk-vulkan = ''
        ${setWineRenderer "gl"}
        ${dxvk}/bin/setup_dxvk.sh install --symlink ${
          lib.optionalString (!dxvkAppliedOptions.enableDXGI) "--without-dxgi"
        } ${lib.optionalString dxvkAppliedOptions.enableD3D10 "--with-d3d10"}
      '';
    }
    ."${renderer}";

  hudCommand =
    {
      wine-opengl = "${mangohud}/bin/mangohud --dlsym";
      wine-vulkan = "${mangohud}/bin/mangohud";
      dxvk-vulkan = "${mangohud}/bin/mangohud";
    }
    ."${renderer}";

  dxvkCacheSetupScript =
    let
      path = "$HOME/.cache/dxvk-cache/${attrs.pname}";
    in
    if renderer != "dxvk-vulkan" then
      ""
    else
      ''
        mkdir -p "${path}"
        export DXVK_STATE_CACHE_PATH="${path}"
      '';

  withFileMap =
    let
      wineMajorVersion = lib.versions.major wine.version;
      defaultExtraFileMap = {
        "$HOME/.config/mkWindowsApp/${attrs.pname}/wine-${wineMajorVersion}/user.reg" = "user.reg";
        "$HOME/.config/mkWindowsApp/${attrs.pname}/wine-${wineMajorVersion}/system.reg" = "system.reg";
      };

      extraFileMap =
        if persistRegistry then
          (
            if enableVulkan then
              abort "The mkWindowsApp function attributes 'persistRegistry' can't be used along with 'enableVulkan' (DXVK) at this time because it would lead to a failed DXVK installation."
            else
              defaultExtraFileMap
          )
        else
          { };
    in
    f:
    builtins.concatStringsSep "\n" (
      builtins.attrValues (builtins.mapAttrs f (fileMap // extraFileMap))
    );

  fileMappingScript = withFileMap (src: dest: ''map_file "${src}" "${dest}"'');
  persistFilesScript = withFileMap (dest: src: ''persist_file "${src}" "${dest}"'');

  # Wine DLL overrides which are used *only* when the Wine prefix is created.
  # It may be useful to expose this as an argument to mkWindowsApp.
  # But for now it's only used internally.
  bootDLLOverrides = if enableMonoBootPrompt then "" else "mscoree=d;mshtml=d";

  winLayerHash =
    {
      "store-path" = builtins.hashString "sha256" "${wine} ${bootDLLOverrides} ${api}";
      "version" = builtins.hashString "sha256" "${wine.version} ${bootDLLOverrides} ${api}";
    }
    ."${inputHashMethod}";

  appLayerHash =
    {
      "store-path" = "@APP_LAYER_HASH@";
      "version" = builtins.hashString "sha256" "${name} ${api}";
    }
    ."${inputHashMethod}";

  inputHashScript = ''
    WIN_LAYER_HASH=${winLayerHash}
    APP_LAYER_HASH=${appLayerHash}
  '';

  wineUserProfileSymlinkScript =
    let
      dirs = {
        "desktop" = "Desktop";
        "documents" = "Documents";
        "downloads" = "Downloads";
        "music" = "Music";
        "pictures" = "Pictures";
        "videos" = "Videos";
      };

      cfg =
        (builtins.listToAttrs (
          builtins.map (dir: {
            name = dir;
            value = true;
          }) (builtins.attrNames dirs)
        ))
        // enabledWineSymlinks;

      disableSymlink = name: ''
        rm "$WINEPREFIX/drive_c/users/$USER/${name}";
        mkdir -p "$WINEPREFIX/drive_c/users/$USER/${name}";
      '';

    in
    builtins.concatStringsSep "\n" (
      builtins.map (name: disableSymlink dirs."${name}") (
        builtins.filter (name: cfg."${name}" == false) (builtins.attrNames cfg)
      )
    );

  launcher = writeShellScript "wine-launcher" ''
    source ${libwindowsapp}
    PATH="${
      makeBinPath (
        [
          coreutils
          wine
          winetricks
          cabextract
          gnused
          unionfs-fuse
          libnotify
          util-linux
        ]
        ++ buildInputs
      )
    }:$PATH"
    MY_PATH="@MY_PATH@"
    OUT_PATH="@out@"
    ARGS="$@"
    WINE=${
      if (builtins.pathExists "${wine}/bin/wine64") then "${wine}/bin/wine64" else "${wine}/bin/wine"
    }
    ${inputHashScript}
    RUN_LAYER_HASH=@RUN_LAYER_HASH@
    BUILD_HASH=$(printf "%s %s" $RUN_LAYER_HASH $USER | sha256sum | sed -r 's/(.{64}).*/\1/')
    LOCKFILE="/tmp/$BUILD_HASH.lock"
    WA_RUN_APP=''${WA_RUN_APP:-1}
    WA_CLEAN_APP=''${WA_CLEAN_APP:-0}
    needs_cleanup="1"

    ${graphicsDriverCmd}

    show_notification () {
      local fallback_icon=$1
      local msg=$2
      local icon=$(find -L $(dirname $(dirname $MY_PATH))/share/icons -name *.png | tail -n 1)

      if [ ! -f $icon ]
      then
        icon=$fallback_icon
      fi

      ${
        if enableInstallNotification then
          "notify-send -i $icon \"$msg\""
        else
          "echo 'Notifications are disabled. Ignoring.'"
      }
    }

    ${builtins.readFile (import ./filemap.nix { inherit writeScript rsync; })}

    mk_windows_layer () {
      echo "Building a Windows $WINEARCH layer at $WINEPREFIX..."
      $WINE boot --init
      wineserver -w
    }

    mk_app_layer () {
      echo "Building an app layer at $WINEPREFIX..."
      show_notification "drive-harddisk" "Installing ${attrs.pname}..."
      ${lib.optionalString fileMapDuringAppInstall (
        lib.warn "The mkWindowsApp fileMapDuringAppInstall attribute is deprecated." fileMappingScript
      )}
      ${setupRendererScript}
      ${wineUserProfileSymlinkScript}
      ${winAppInstall}
      wineserver -w
      ${lib.optionalString fileMapDuringAppInstall persistFilesScript}
      show_notification "content-loading" "${attrs.pname} is now installed. Running..."
    }

    run_app () {
      echo "Running Windows app with WINEPREFIX at $WINEPREFIX..."
      ${dxvkCacheSetupScript}

      if [ "$needs_cleanup" == "1" ]
      then
        echo "Running winAppPreRun."
        ${fileMappingScript}
        ${winAppPreRun}
      fi

      if [ $WA_RUN_APP -eq 1 ]
      then
        ${lib.optionalString enableHUD "export MANGOHUD=\"${hudCommand}\""}
        DPI=$(${lib.getExe pkgs.xorg.xrdb} -query | ${lib.getExe pkgs.gawk} '/Xft.dpi/ {print int($2)}')
        $WINE reg add "HKCU\Control Panel\Desktop" /v LogPixels /t REG_DWORD /d $DPI /f
        $WINE reg add "HKCU\Control Panel\Desktop" /v Win8DpiScaling /t REG_DWORD /d 1 /f
        ${winAppRun}
        ${lib.optionalString inhibitIdle "${systemd}/bin/systemd-inhibit --no-ask-password --what=idle --who=\"${attrs.pname}\" --why=\"To prevent the screen from turning off.\" --mode=block"} wineserver -w
      else
        echo "WA_RUN_APP is not set to 1. Starting a bash shell instead of running the app. When you're done, please exit the shell."
        bash
      fi

      if [ "$needs_cleanup" == "1" ]
      then
        echo "Running winAppPostRun."
        ${winAppPostRun}
        ${persistFilesScript}
      fi
    }

    mkdir $LOCKFILE
    lockstatus=$?

    if [ "$lockstatus" == "1" ]
    then
      echo "ERROR: ${attrs.pname} has not finished installing."
      exit
    fi

    wa_init ${wineArch} $BUILD_HASH
    win_layer=$(wa_init_layer $WIN_LAYER_HASH $MY_PATH)
    app_layer=$(wa_init_layer $APP_LAYER_HASH $MY_PATH)
    run_layer=${if persistRuntimeLayer then "$(wa_init_layer $RUN_LAYER_HASH $MY_PATH)" else "\"\""}

    echo "winearch: ${wineArch}"
    echo "windows layer: $win_layer"
    echo "app layer: $app_layer"
    ${lib.optionalString persistRuntimeLayer "echo \"run_layer: $run_layer\""}
    echo "build hash: $BUILD_HASH"
    echo "lock file: $LOCKFILE"

    if [ $WA_CLEAN_APP -eq 1 ]
    then
      if [ -d "$app_layer" ]
      then
        echo "Deleting the app layer..."
        rm -fR $app_layer
      fi

      if [[ -n "$run_layer" && -d "$run_layer" ]]
      then
        echo "Deleting the run layer..."
        rm -fR $run_layer
      fi

      rmdir $LOCKFILE
      echo "Cleaning complete."
      exit
    fi

    if [ -d "$win_layer" ]
    then
      if [ ! -d "$app_layer" ]
      then
        bottle=$(wa_init_bottle $win_layer $app_layer)
        wa_with_bottle $bottle "" "mk_app_layer"
        wa_remove_bottle $bottle
        wa_close_layer $APP_LAYER_HASH
      fi
    else
      if [ -d "$app_layer" ]
      then
        rm -fR "$app_layer"
        app_layer=$(wa_init_layer $APP_LAYER_HASH $MY_PATH)
      fi

      bottle=$(wa_init_bottle $win_layer $app_layer)
      wa_with_bottle $bottle "${bootDLLOverrides}" "mk_windows_layer"
      wa_remove_bottle $bottle
      wa_close_layer $WIN_LAYER_HASH

      bottle=$(wa_init_bottle $win_layer $app_layer)
      wa_with_bottle $bottle "" "mk_app_layer"
      wa_remove_bottle $bottle
      wa_close_layer $APP_LAYER_HASH
    fi

    ${lib.optionalString persistRuntimeLayer "wa_close_layer $RUN_LAYER_HASH \"1\""}

    rmdir $LOCKFILE
    echo "Windows and app layers are initialized.";

    if [ $(wa_is_bottle_initialized $win_layer $app_layer) == "1" ]
    then
      needs_cleanup="0"
      bottle=$(wa_get_bottle_dir $win_layer $app_layer)
    else
      bottle=$(wa_init_bottle $win_layer $app_layer $run_layer)
    fi

    wa_with_bottle $bottle "" "run_app"
    echo "App exited.";

    if [ "$needs_cleanup" == "1" ]
    then
      wa_remove_bottle $bottle
    fi
  '';
in
stdenv.mkDerivation (
  (builtins.removeAttrs attrs [
    "fileMap"
    "enabledWineSymlinks"
    "dxvkOptions"
  ])
  // {

    preInstall = ''
      APP_LAYER_HASH=${
        if appLayerHash == "@APP_LAYER_HASH@" then
          ''$(printf "%s %s" "$out/bin/.launcher" "${api}" | sha256sum | sed -r "s/(.{64}).*/\1/")''
        else
          appLayerHash
      }
      RUN_LAYER_HASH=$(printf "%s %s" ${winLayerHash} $APP_LAYER_HASH | sha256sum | sed -r 's/(.{64}).*/\1/')

      mkdir -p $out/bin

      cp ${launcher} $out/bin/.launcher
      substituteInPlace $out/bin/.launcher \
        --subst-var-by MY_PATH $out/bin/.launcher \
        --subst-var out \
        --subst-var APP_LAYER_HASH \
        --subst-var RUN_LAYER_HASH
    '';
  }
)
