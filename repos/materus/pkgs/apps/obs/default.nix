{ config
, lib
, stdenv
, fetchFromGitHub
, addOpenGLRunpath
, cmake
, fdk_aac
, ffmpeg
, jansson
, libjack2
, libxkbcommon
, libpthreadstubs
, libXdmcp
, qtbase
, qtsvg
, speex
, libv4l
, x264
, curl
, wayland
, xorg
, pkg-config
, libvlc
, mbedtls
, wrapGAppsHook
, scriptingSupport ? true
, luajit
, swig4
, python3
, alsaSupport ? stdenv.isLinux
, alsa-lib
, pulseaudioSupport ? config.pulseaudio or stdenv.isLinux
, libpulseaudio
, pciutils
, pipewireSupport ? stdenv.isLinux
, pipewire
, libdrm
, libajantv2
, librist
, libva
, srt
, qtwayland
, wrapQtAppsHook
, nlohmann_json
, asio
, websocketpp
, amf-headers 
, libGL
, vulkan-loader
, decklinkSupport ? false
, blackmagic-desktop-video ? null
, libcef
, libdatachannel 
, pkgs
, qrcodegencpp ? pkgs.callPackage ./qrcodegencpp.nix {}
, onevpl ? pkgs.callPackage ./onevpl.nix {}
}:
assert (!decklinkSupport || blackmagic-desktop-video!=null) || builtins.throw "decklinkSupport enabled but blackmagic-desktop-video is null";
let
  inherit (lib) optional optionals;
in
stdenv.mkDerivation rec {
  pname = "obs-studio-amf";
  version = "30.0.2";
  src = fetchFromGitHub {
    owner = "obsproject";
    repo = "obs-studio";
    rev = version;
    sha256 = "sha256-8pX1kqibrtDIaE1+/Pey1A5bu6MwFTXLrBOah4rsF+4=";
    fetchSubmodules = true;
  };

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error"
  ];
  patches = [
    ./obs-amf-patch.patch # OBS AMF Patch
    ./Enable-file-access-and-universal-access-for-file-URL.patch
    ./fix-nix-plugin-path.patch
    ./av1-vaapi.patch
    ./ffmpeg61.patch
  ];

  nativeBuildInputs = [
    addOpenGLRunpath
    cmake
    pkg-config
    wrapGAppsHook
    wrapQtAppsHook
  ]
  ++ optional scriptingSupport swig4;

  buildInputs = [
    amf-headers 
    websocketpp
    asio
    nlohmann_json
    curl
    fdk_aac
    ffmpeg
    jansson
    libcef
    libjack2
    libv4l
    libxkbcommon
    libpthreadstubs
    libXdmcp
    qtbase
    qtsvg
    speex
    wayland
    x264
    libvlc
    mbedtls
    pciutils
    libajantv2
    librist
    libva
    srt
    qtwayland
    libdatachannel
    qrcodegencpp
    onevpl
  ]
  ++ optionals scriptingSupport [ luajit python3 ]
  ++ optional alsaSupport alsa-lib
  ++ optional pulseaudioSupport libpulseaudio
  ++ optionals pipewireSupport [ pipewire libdrm ];

  # Copied from the obs-linuxbrowser
  postUnpack = ''
    cp -rs ${libcef}/share/cef cef
  '';

  # obs attempts to dlopen libobs-opengl, it fails unless we make sure
  # DL_OPENGL is an explicit path. Not sure if there's a better way
  # to handle this.
  cmakeFlags = [
    "-DOBS_VERSION_OVERRIDE=${version}"
    "-Wno-dev" # kill dev warnings that are useless for packaging
    # Add support for browser source
    "-DBUILD_BROWSER=ON"
    "-DCEF_ROOT_DIR=../../cef"
    "-DENABLE_JACK=ON"
  ];

  dontWrapGApps = true;
  preFixup =  let
    wrapperLibraries = [
      xorg.libX11
      libvlc
    ] ++ optionals decklinkSupport [
      blackmagic-desktop-video
    ];
  in
  ''
    #Remove libs from libcef, they are symlinks and can't be patchelfed 
    rm $out/lib/obs-plugins/libcef.so $out/lib/obs-plugins/libEGL.so $out/lib/obs-plugins/libGLESv2.so $out/lib/obs-plugins/libvk_swiftshader.so
    
    #Suffix on libgl and vulkan-loader so it can be overriden by helper scripts from amdgpu-pro
    qtWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "$out/lib:${lib.makeLibraryPath wrapperLibraries}"
      --suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL vulkan-loader ]}"
      ''${gappsWrapperArgs[@]}
    )
  '';

  postFixup = lib.optionalString stdenv.isLinux ''
    addOpenGLRunpath $out/lib/lib*.so
    addOpenGLRunpath $out/lib/obs-plugins/*.so
    
    ##Symlink libcef related things after patchelfing
    ln -s ${libcef}/share/cef/Release/libcef.so $out/lib/obs-plugins/libcef.so

    #OBS seems to need those to be from libcef for hardware acceleration (at least on AMD card)
    ln -s ${libcef}/share/cef/Release/libEGL.so $out/lib/obs-plugins/libEGL.so 
    ln -s ${libcef}/share/cef/Release/libGLESv2.so  $out/lib/obs-plugins/libGLESv2.so 

    #Doesn't seem needed but added anyway
    ln -s ${libcef}/share/cef/Release/libvk_swiftshader.so $out/lib/obs-plugins/libvk_swiftshader.so
  '';

  meta = with lib; {
    description = "Free and open source software for video recording and live streaming. With AMD AMF";
    longDescription = ''
      This project is a rewrite of what was formerly known as "Open Broadcaster
      Software", software originally designed for recording and streaming live
      video content, efficiently
    '';
    homepage = "https://obsproject.com";
    maintainers = with maintainers; [ ];
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "obs";
  };
}