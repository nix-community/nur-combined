{ lib, stdenv, fetchFromGitHub, cmake, pkg-config
, libX11, freetype, fontconfig, alsa-lib, libXrandr, libXinerama, libXcursor
, libXext }:

stdenv.mkDerivation (finalAttrs: {
  pname = "ripplerx";
  version = "1.5.18";

  src = fetchFromGitHub {
    owner = "tiagolr";
    repo = "ripplerx";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-lHLAJ8eCmn/WFYxGl/zIq8a2xPKqzpB7tilffJcXhM4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [
    libX11
    freetype
    fontconfig
    alsa-lib
    libXrandr
    libXinerama
    libXcursor
    libXext
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'COPY_PLUGIN_AFTER_BUILD TRUE' 'COPY_PLUGIN_AFTER_BUILD FALSE'

    substituteInPlace CMakeLists.txt \
      --replace-fail 'juce::juce_recommended_lto_flags' '# Not forcing LTO'
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  NIX_LDFLAGS = (
    toString [
      "-lX11"
      "-lXext"
      "-lXcursor"
      "-lXinerama"
      "-lXrandr"
    ]
  );

  installPhase = ''
    install -Dm755 {RipplerX_artefacts/Release/Standalone,$out/bin}/RipplerX
    mkdir -p $out/lib/vst3
    mv RipplerX_artefacts/Release/VST3/* $out/lib/vst3
    mv RipplerX_artefacts/Release/LV2/* $out/lib/lv2/RipplerX.lv2
  '';

  meta = with lib; {
    description = "A physically modeled synth, capable of sounds similar to AAS Chromaphone and Ableton Collision";
    homepage = "https://github.com/tiagolr/ripplerx";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = [ lib.maintainers.suhr ];
  };
})
