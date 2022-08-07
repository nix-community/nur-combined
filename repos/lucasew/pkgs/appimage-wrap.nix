{ buildFHSUserEnv
, writeShellScriptBin
, ... }:
let
  fhs = buildFHSUserEnv {
    name = "appimage-env";

    # Most of the packages were taken from the Steam chroot
    targetPkgs = pkgs: with pkgs; [
      gtk3
      bashInteractive
      gnome.zenity
      python2
      xorg.xrandr
      which
      perl
      xdg-utils
      iana-etc
      krb5
      gsettings-desktop-schemas
      hicolor-icon-theme # dont show a gtk warning about hicolor not being installed
    ];

    # list of libraries expected in an appimage environment:
    # https://github.com/AppImage/pkg2appimage/blob/master/excludelist
    multiPkgs = pkgs: with pkgs; [
      # extra
      fuse
      fuse3
      (writeShellScriptBin "sudo" "true") # suid wrappers messing with suff
      pulseaudio
      vulkan-loader
      mesa
      libglvnd
      mesa_drivers

      desktop-file-utils
      xorg.libXcomposite
      xorg.libXtst
      xorg.libXrandr
      xorg.libXext
      xorg.libX11
      xorg.libXfixes
      libGL

      gst_all_1.gstreamer
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-plugins-base
      libdrm
      xorg.xkeyboardconfig
      xorg.libpciaccess

      glib
      gtk2
      bzip2
      zlib
      gdk-pixbuf

      xorg.libXinerama
      xorg.libXdamage
      xorg.libXcursor
      xorg.libXrender
      xorg.libXScrnSaver
      xorg.libXxf86vm
      xorg.libXi
      xorg.libSM
      xorg.libICE
      gnome2.GConf
      freetype
      (curl.override { gnutlsSupport = true; opensslSupport = false; })
      nspr
      nss
      fontconfig
      cairo
      pango
      expat
      dbus
      cups
      libcap
      SDL2
      libusb1
      udev
      dbus-glib
      atk
      at-spi2-atk
      libudev0-shim

      xorg.libXt
      xorg.libXmu
      xorg.libxcb
      xorg.xcbutil
      xorg.xcbutilwm
      xorg.xcbutilimage
      xorg.xcbutilkeysyms
      xorg.xcbutilrenderutil
      libGLU
      libuuid
      libogg
      libvorbis
      SDL
      SDL2_image
      glew110
      openssl
      libidn
      tbb
      wayland
      mesa
      libxkbcommon

      flac
      freeglut
      libjpeg
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
      libcaca
      libcanberra
      libgcrypt
      libvpx
      librsvg
      xorg.libXft
      libvdpau
      alsa-lib

      harfbuzz
      e2fsprogs
      libgpg-error
      keyutils.lib
      libjack2
      fribidi
      p11-kit

      gmp

      # libraries not on the upstream include list, but nevertheless expected
      # by at least one appimage
      libtool.lib # for Synfigstudio
      xorg.libxshmfence # for apple-music-electron
      at-spi2-core
    ];

    runScript = ''

    PATH=$(echo "$PATH" | sed 's;/run/wrappers/bin:;;g')

    "$@"
    '';
  };
in writeShellScriptBin "appimage-wrap" ''
PATH=$PATH:${fhs}/bin
APPIMAGE="$1"; shift
OFFSET="$(appimage-env "$APPIMAGE" --appimage-offset | head -n 1)"
LOOP=$(udisksctl loop-setup -f "$APPIMAGE" --offset "$OFFSET" | sed 's;[ \.];\n;g' | grep '/dev/loop')
MOUNTPOINT=$(udisksctl mount -b $LOOP | sed 's;[ \.];\n;g' | grep '/media')
if [ ! -z "$MOUNTPOINT" ]; then
  appimage-env "$MOUNTPOINT/AppRun" "$@"
fi
if [ ! -z "$LOOP" ]; then
  notify-send "Trying to unmount the appimage"
  while true; do
    if [[ ! "$(udisksctl unmount -b "$LOOP" 2>&1 || true)" =~ "Error" ]]; then
      break
    fi
    sleep 1
  done
  while true; do
    udisksctl loop-delete -b "$LOOP" && break || true
    sleep 1
  done
  notify-send "AppImage unmounted"
else
  notify-send "Can't mount the AppImage"
fi
''
