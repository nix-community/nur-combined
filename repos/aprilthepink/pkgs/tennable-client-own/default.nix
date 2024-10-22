{ lib, buildFHSEnv, writeShellScriptBin, writeShellScript, fetchurl, dpkg, stdenv }:

let
  version = "10.5.1";

  src = fetchurl {
    url = "https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/downloads/24295/download?i_agree_to_tenable_license_agreement=true";
    sha256 = "sha256-cmYhqQSevxCUBLHeuhK/HWgPqqksgyWKXpbSpnDOvZk=";
  };

  nessus-agent-install = writeShellScriptBin "nessus-agent-install" ''
    set -euo pipefail
    if [ -d /opt/nessus_agent ]; then
      echo "Nessus Agent already installed to /opt/nessus_agent"
      exit 0
    fi
    ${dpkg}/bin/dpkg-deb --fsys-tarfile '${src}' | tar x -C / ./opt/nessus_agent
    echo "Nessus Agent installed to /opt/nessus_agent"
  '';

  
  ldPath = lib.optionals stdenv.is64bit [ "/lib64" ]
  ++ [ "/lib32" ];

  exportLDPath = ''
    export LD_LIBRARY_PATH=${lib.concatStringsSep ":" ldPath}''${LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH
    export STEAM_LD_LIBRARY_PATH="$STEAM_LD_LIBRARY_PATH''${STEAM_LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH"
  '';

  envScript = ''
    # prevents various error messages
    unset GIO_EXTRA_MODULES

    # This is needed for IME (e.g. iBus, fcitx5) to function correctly on non-CJK locales
    # https://github.com/ValveSoftware/steam-for-linux/issues/781#issuecomment-2004757379
    GTK_IM_MODULE='xim'
  '';
in
buildFHSEnv {
  name = "nessus-agent-shell";
  inherit version;

  multiArch = true;

  targetPkgs = pkgs: with pkgs; [ 
    nessus-agent-install
    nix
    coreutils
    tzdata
    nettools
    iproute2
    procps
    util-linux
    lsb-release
    pciutils
    glibc.bin
    xorg.xrandr
    which
    perl
    xdg-utils
    iana-etc
    python3
  ];

  multiPkgs = pkgs: with pkgs; [
    # These are required by steam with proper errors
    xorg.libXcomposite
    xorg.libXtst
    xorg.libXrandr
    xorg.libXext
    xorg.libX11
    xorg.libXfixes
    libGL
    libva
    pipewire

    # steamwebhelper
    harfbuzz
    libthai
    pango

    lsof # friends options won't display "Launch Game" without it
    file # called by steam's setup.sh

    # dependencies for mesa drivers, needed inside pressure-vessel
    mesa.llvmPackages.llvm.lib
    vulkan-loader
    expat
    wayland
    xorg.libxcb
    xorg.libXdamage
    xorg.libxshmfence
    xorg.libXxf86vm
    elfutils

    # Without these it silently fails
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXi
    xorg.libSM
    xorg.libICE
    gnome2.GConf
    curlWithGnuTls
    nspr
    nss
    cups
    libcap
    SDL2
    libusb1
    dbus-glib
    gsettings-desktop-schemas
    ffmpeg
    libudev0-shim

    # Verified games requirements
    fontconfig
    freetype
    xorg.libXt
    xorg.libXmu
    libogg
    libvorbis
    SDL
    SDL2_image
    glew110
    libdrm
    libidn
    tbb
    zlib

    # SteamVR
    udev
    dbus

    # Other things from runtime
    glib
    gtk2
    bzip2
    flac
    freeglut
    libjpeg
    libpng
    libpng12
    libsamplerate
    libmikmod
    libtheora
    libtiff
    pixman
    speex
    SDL_image
    SDL_ttf
    SDL_mixer
    SDL2_ttf
    SDL2_mixer
    libappindicator-gtk2
    libdbusmenu-gtk2
    libindicator-gtk2
    libcaca
    libcanberra
    libgcrypt
    libunwind
    libvpx
    librsvg
    xorg.libXft
    libvdpau

    # required by coreutils stuff to run correctly
    # Steam ends up with LD_LIBRARY_PATH=<bunch of runtime stuff>:/usr/lib:<etc>
    # which overrides DT_RUNPATH in our binaries, so it tries to dynload the
    # very old versions of stuff from the runtime.
    # FIXME: how do we even fix this correctly
    attr
  ];

  runScript = writeShellScript "gay-wrapper.sh" ''
    ${exportLDPath}

    set -o allexport # Export the following env vars
    ${envScript}
    bash -l
  '';

  meta = with lib; {
    description = "Tenable Nessus Agent Installer";
    homepage = "https://www.tenable.com/products/nessus/nessus-agents";
    # license = licenses.unfree;
    maintainers = with maintainers; [ aprl ];
    platforms = platforms.linux;
  };
}
