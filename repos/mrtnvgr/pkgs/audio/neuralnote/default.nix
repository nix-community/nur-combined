# Thanks to @polygon!
{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, alsa-lib
, freetype
, webkitgtk
, curl
, fftwFloat
, jack2
, xorg
, pcre2
, pcre
, libuuid
, libselinux
, libsepol
, libthai
, libdatrie
, libxkbcommon
, libepoxy
, libsysprof-capture
, sqlite
, libpsl
, callPackage
}:
let
  buildType = "Release";
  libonnxruntime-neuralnote = callPackage ./libonnxruntime-neuralnote.nix { };
in
stdenv.mkDerivation rec {
  pname = "NeuralNote";
  version = "162e2c93083358c9e3e4c0bd9ff4f4016ead2c32";

  src = fetchFromGitHub {
    owner = "polygon";
    repo = pname;
    rev = version;
    sha256 = "sha256-iMjD4evVmM6yo3g0k5Apfm1AhikL5G+WpoCIafDpy5o=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [
    freetype
    alsa-lib
    webkitgtk
    curl
    fftwFloat
    jack2
    xorg.libX11
    xorg.libXext
    xorg.libXinerama
    xorg.xrandr
    xorg.libXcursor
    xorg.libXfixes
    xorg.libXrender
    xorg.libXScrnSaver
  ];

  # JUCE dlopens these, make sure they are in rpath
  # Otherwise, segfault will happen
  NIX_LDFLAGS = (toString [
    "-lX11"
    "-lXext"
    "-lXcursor"
    "-lXinerama"
    "-lXrandr"
  ]);

  # Needed for LTO to work, currently unsure as to why
  cmakeFlags = [
    "-DCMAKE_AR=${stdenv.cc.cc}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${stdenv.cc.cc}/bin/gcc-ranlib"
    "-DCMAKE_NM=${stdenv.cc.cc}/bin/gcc-nm"
  ];

  postPatch = ''
    sed -i -e 's/if (canDrop)/if (1)/' ThirdParty/JUCE/modules/juce_gui_basics/native/x11/juce_linux_X11_DragAndDrop.cpp
    cd ThirdParty
    rm -rf onnxruntime || true
    mkdir onnxruntime
    cd onnxruntime
    tar xf ${libonnxruntime-neuralnote}/libonnxruntime-neuralnote.tar.gz
    mv model.with_runtime_opt.ort ../../Lib/ModelData/features_model.ort
    cd ../..
  '';

  cmakeBuildType = buildType;

  installPhase =
    let
      vst3path = "${placeholder "out"}/lib/vst3";
      binpath = "${placeholder "out"}/bin";
    in
    ''
      runHook preInstall

      mkdir -p ${vst3path}
      mkdir -p ${binpath}

      cp -R NeuralNote_artefacts/${buildType}/VST3/* ${vst3path}
      cp -R NeuralNote_artefacts/${buildType}/Standalone/* ${binpath}

      runHook postInstall
    '';

  meta = with lib; {
    description = "Audio Plugin for Audio to MIDI transcription using deep learning";
    homepage = "https://github.com/DamRsn/NeuralNote";
    license = licenses.asl20;
    platforms = platforms.linux;
    broken = true;
  };
}
