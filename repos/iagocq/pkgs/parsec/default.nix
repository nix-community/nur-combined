# based on https://github.com/clefru/nur-packages/blob/master/pkgs/parsecgaming/default.nix

{ lib
, stdenv
, buildFHSUserEnv
, fetchurl
, copyDesktopItems
, curl
, jq
, writeScript
, dpkg
, alsa-lib
, cups
, dbus
, fontconfig
, freetype
, libGL
, libsamplerate
, makeDesktopItem
, udev
, libva
, vaapiVdpau
, libxkbcommon
, nas
, vulkan-loader
, libX11
, libXScrnSaver
, libXcursor
, libXext
, libXi
, libXinerama
, libXrandr
, libXrender
, libXxf86vm
, libxcb
, openssl
, extraPkgs ? [ ]
}:

let
  version = "150-78";

  src = stdenv.mkDerivation {
    name = "parsec-pkg";
    src = fetchurl {
      url = "https://s3.amazonaws.com/parsec-build/package/parsec-linux.deb";
      sha256 = "1hfdzjd8qiksv336m4s4ban004vhv00cv2j461gc6zrp37s0fwhc";
    };
    phases = [ "buildPhase" ];
    buildInputs = [ dpkg ];
    buildPhase = ''
      mkdir $out
      dpkg-deb -x $src $out
      # dpkg-deb makes $out group-writable, which nix doesn't like
      chmod 755 $out
      mv $out/usr/* $out
      rmdir $out/usr
    '';
  };

  launchScript = writeScript "update-appdata-and-launch-parsec" ''
    #! ${stdenv.shell}
    set -exuo pipefail
    curl=${curl}/bin/curl
    jq=${jq}/bin/jq

    pushd $HOME

    if [ ! -d .parsec ]; then
      rm -f .parsec
      mkdir .parsec
    fi

    cd .parsec

    outdated=""
    if [ ! -e appdata.json ]; then
      outdated=y
    else
      so_version=$($jq -r .so_name appdata.json | grep -o '[0-9]\+-[0-9]\+')
      [[ "${version}" > "$so_version" ]] && outdated=y
    fi

    if [ "$outdated" ]; then
      rm -f appdata.json
      $curl -L -o appdata.json https://builds.parsecgaming.com/channel/release/appdata/linux/latest
      so_name=$($jq -r .so_name appdata.json)
      if [ ! -e $so_name ]; then
        $curl -L -O https://builds.parsecgaming.com/channel/release/binary/linux/gz/$so_name
      fi
    fi

    popd
    /usr/bin/parsecd
  '';

  linkAlsaConf = stdenv.mkDerivation {
    name = "parsec-alsa-conf";
    buildCommand = ''
      mkdir -p $out/etc
      cd $out/etc
      ln -s /host/etc/alsa alsa
    '';
  };

  fhsEnv = buildFHSUserEnv {
    name = "parsec-fhs-wrapper";
    targetPkgs = pkgs: [
      alsa-lib
      cups
      dbus
      src
      fontconfig
      freetype
      libGL
      libsamplerate
      udev
      libva
      vaapiVdpau
      libxkbcommon
      nas
      vulkan-loader
      libX11
      libXScrnSaver
      libXcursor
      libXext
      libXi
      libXinerama
      libXrandr
      libXrender
      libXxf86vm
      libxcb
      openssl
      stdenv.cc.cc.lib
      linkAlsaConf
      # Those libraries are missing from buildInputs
      # libGLES_CM.so.1        # Can't find in my /nix/store
      # libudev.so.0           # Covered by libudev.so.1
      # libva.so.1             # Covered by libva.so.2
      # libwayland-client.so.0 # No wayland support
      # libwayland-cursor.so.0 # No wayland support
      # libwayland-egl.so.1    # No wayland support
    ] ++ extraPkgs;
    runScript = launchScript;
  };
in
stdenv.mkDerivation rec {
  pname = "parsec";
  inherit version;

  nativeBuildInputs = [ copyDesktopItems ];
  desktopItems = [
    (makeDesktopItem {
      name = "parsec";
      desktopName = "Parsec";
      comment = "Simple, low-latency game streaming.";
      exec = "parsec %u";
      icon = "parsecd";
      categories = [ "Network" "Game" "Utility" ];
    })
  ];

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir $out
    runHook preInstall
    mkdir $out/bin
    ln -s ${fhsEnv}/bin/parsec-fhs-wrapper $out/bin/parsec
    for d in ${src}/share/icons/hicolor/*; do
      install -Dm0644 -t $out/share/icons/hicolor/$(basename $d)/apps/ $d/apps/parsecd.png
    done
    runHook postInstall
  '';

  meta = with lib; {
    description = "Simple, low-latency game streaming.";
    homepage = "https://parsec.app";
    license = licenses.unfree;
  };
}
