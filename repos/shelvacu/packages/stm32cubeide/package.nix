{
  lib,
  stdenv,
  requireFile,
  runCommand,
  gnugrep,
  unzip,
  makeWrapper,
  swt_4_33,
  autoPatchelfHook,

  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libGL,
  libudev0-shim,
  libxkbcommon,
  libgbm,
  nspr,
  nss,
  pango,
  xorg,
  libgcrypt,
  openssl,
  udev,
  ncurses5,
  ffmpeg_7,
  ffmpeg_6,
  ffmpeg_4,
  pcsclite,
  krb5,
  kdePackages,
  gsettings-desktop-schemas,
}:
let
  swt = swt_4_33;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "stm32cubeide";
  version = "1.19.0";

  src = finalAttrs.passthru.extracted;

  passthru = {
    zip = requireFile {
      name = "st-stm32cubeide_1.19.0_25607_20250703_0907_amd64.sh.zip";
      url = "https://www.st.com/en/development-tools/stm32cubeide.html#get-software";
      hash = "sha256-+jeXv7+ywRhgQAIl7aFCnRzhbVJZPlW6JICvGLacPG0=";
      hashMode = "flat";
    };
    extracted =
      runCommand "${finalAttrs.pname}-src-extracted"
        {
          nativeBuildInputs = [
            gnugrep
            unzip
            ./extract_makeself.bash
          ];
        }
        ''
          (
            set -euo pipefail
            set -xv
            zip=${lib.escapeShellArg finalAttrs.passthru.zip}
            declare fileList
            fileList="$(unzip -Z -1 "$zip")"
            declare -i countFiles
            countFiles="$(printf '%s\n' "$fileList" | wc -l)"
            if [[ $countFiles != 1 ]]; then
              echo "Error: Expected exactly 1 file in the zip, but there were $countFiles files" >&2
              exit 1
            fi

            mkdir -p "$out"
            extract_makeself_from_command "$out" unzip -p "$zip"
          )
        '';
  };

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libGL
    libudev0-shim
    libxkbcommon
    libgbm
    nspr
    nss
    pango
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libXtst
    xorg.libXxf86vm
    xorg.xcbutilwm
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    libgcrypt
    openssl
    udev
    ncurses5
    ffmpeg_7
    ffmpeg_6
    ffmpeg_4
    pcsclite
    krb5
    kdePackages.qtwayland
    swt
    gsettings-desktop-schemas
  ];

  strictDeps = true;

  doConfigure = false;
  doBuild = false;
  dontWrapQtApps = true;
  installPhase = ''
    mainDir="$out"/share/stm32cubeide
    mkdir -p "$mainDir"
    tar -xf *.tar.gz -C "$mainDir"
    mkdir -p "$out"/share/applications
    bash ./desktop_shortcut.sh ${
      lib.escapeShellArg (finalAttrs.version + "-nix")
    } "$mainDir" "$out"share/applications/st-stm32cubeide-${finalAttrs.version}.desktop
    binDir="$out"/bin
    mkdir -p "$binDir"

    declare -a cmd
    cmd=(
      wrapProgram "$mainDir/stm32cubeide"
      --argv0 "$mainDir/stm32cubeide"
      --set GDK_BACKEND x11
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH"
      --run 'xdgConfigDir="''${XDG_CONFIG_HOME:-"$HOME"/.config}"'
      --run 'cubeConfigDir="$xdgConfigDir/stm32cubeide-nix"'
      --run 'mkdir -p "$cubeConfigDir"/{system/.systemPrefs,user}'
      --run 'touch "$cubeConfigDir/system/.systemPrefs/.system.lock"'
      --run 'export JAVA_TOOL_OPTIONS="''${JAVA_TOOL_OPTIONS:-} -Djava.util.prefs.systemRoot=$cubeConfigDir/system -Djava.util.prefs.userRoot=$cubeConfigDir/user -Dswt.library.path=${swt}/lib"'
    )
    "''${cmd[@]}"
    unset cmd

    # rm "$mainDir"/headless-build.sh
    declare -a cmd
    # based on headless-build.sh
    cmd=(
      makeWrapper "$mainDir/stm32cubeide" "$binDir/stm32cubeide-headless-build"
      --add-flags '--launcher.suppressErrors -nosplash -application org.eclipse.cdt.managedbuilder.core.headlessbuild'
    )
    "''${cmd[@]}"
    unset cmd

    ln -s "$mainDir/stm32cubeide" "$binDir/stm32cubeide"
    addAutoPatchelfSearchPath "$mainDir"
    ignoreMissingDepsArray+=(libav{codec,format}.so.{54,56,57,59} libav{codec,format}-ffmpeg.so.56 libxerces-c-3.2.so)
  '';

  meta = {
    mainProgram = "stm32cubeide";
    license = [ lib.licenses.unfree ];
  };
})
