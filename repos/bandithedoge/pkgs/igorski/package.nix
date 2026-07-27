{
  sources,

  lib,
  stdenv,

  cairo,
  cmake,
  freetype,
  glib,
  juceCmakeHook,
  libx11,
  libxcb-cursor,
  libxcb-keysyms,
  libxcb-util,
  libxkbcommon,
  ninja,
  pango,
  pkg-config,
  sqlite,
}:
let
  mkJuce =
    {
      source,
      meta,
    }:
    stdenv.mkDerivation {
      inherit (source) pname src;
      version = lib.removePrefix "v" source.version;

      nativeBuildInputs = [ juceCmakeHook ];

      postPatch = ''
        ln -s ${sources.juce.src} JUCE
      '';

      meta = {
        license = lib.licenses.gpl3Only;
        platforms = lib.platforms.linux;
      }
      // meta;
    };

  mkVst3 =
    {
      source,
      meta,
    }:
    let
      commonBuildInputs = [
        cairo
        freetype
        glib
        libx11
        libxcb-cursor
        libxcb-keysyms
        libxcb-util
        libxkbcommon
        pango
      ];

      vst3sdk = stdenv.mkDerivation {
        inherit (sources.vst3sdk) pname version src;

        nativeBuildInputs = [
          cmake
          ninja
          pkg-config
        ];

        buildInputs = [
          sqlite
        ]
        ++ commonBuildInputs;

        postPatch = ''
          substituteInPlace cmake/modules/SMTG_VstGuiSupport.cmake \
            --replace-fail "set(VSTGUI_STANDALONE ON)" ""

          substituteInPlace vstgui4/vstgui/lib/finally.h \
            --replace-fail "other.invoke (false)" "other.invoke = false"

          patchShebangs vstgui4/vstgui/uidescription/editing/createuidescdata.sh
        '';

        installPhase = ''
          runHook preInstall

          cp -r /build/source $out

          runHook postInstall
        '';

        cmakeFlags = [
          "-DSMTG_ENABLE_VST3_HOSTING_EXAMPLES=OFF"
          "-DSMTG_ENABLE_VST3_PLUGIN_EXAMPLES=OFF"
          "-DSMTG_RUN_VST_VALIDATOR=OFF"
          "-DVSTGUI_STANDALONE=OFF"
          "-DVSTGUI_TOOLS=OFF"
          "-DVST_SDK=ON"
        ];
      };
    in
    stdenv.mkDerivation {
      inherit (source) pname version src;

      nativeBuildInputs = [
        cmake
        ninja
        pkg-config
      ];

      buildInputs = commonBuildInputs;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/lib/vst3
        cp -r VST3/Release/${source.pname}.vst3 $out/lib/vst3

        runHook postInstall
      '';

      cmakeFlags = [
        "-DVST3_SDK_ROOT=${vst3sdk}"
        "-DSMTG_PLUGIN_TARGET_USER_PATH=${builtins.placeholder "out"}"
        "-DSMTG_CREATE_PLUGIN_LINK=OFF"
      ];

      NIX_CFLAGS_COMPILE = [
        "-lpango-1.0"
        "-lpangocairo-1.0"
      ];

      meta = {
        license = lib.licenses.mit;
        platforms = lib.platforms.linux;
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
in
{
  delirion = mkJuce {
    source = sources.delirion;
    meta = {
      description = "A multiband Doppler-based chorusing/detune effect";
      homepage = "https://www.igorski.nl/download/delirion";
    };
  };

  rechoir = mkVst3 {
    source = sources.rechoir;
    meta = {
      description = "VST delay plugin where the repeats are pitch shifted in time to harmonize with the input signal";
      homepage = "https://www.igorski.nl/download/rechoir";
    };
  };

  homecorrupter = mkVst3 {
    source = sources.homecorrupter;
    meta = {
      description = "VST plugin that reduces sampling rate, bit depth and playback speed on-the-fly";
      homepage = "https://www.igorski.nl/download/homecorrupter";
    };
  };

  darvaza = mkVst3 {
    source = sources.darvaza;
    meta = {
      description = "Darvaza is a multichannel audio gate with a twist : whenever the gate closes on your input signal, you get a perversion of your source spat back at you";
      homepage = "https://www.igorski.nl/download/darvaza";
    };
  };

  fogpad = mkVst3 {
    source = sources.fogpad;
    meta = {
      description = "A VST reverb effect in which the reflections can be frozen, filtered, pitch shifted and ultimately disintegrated";
      homepage = "https://www.igorski.nl/download/fogpad";
    };
  };

  regrader = mkVst3 {
    source = sources.regrader;
    meta = {
      description = "VST delay plugin where the repeats degrade in resolution";
      homepage = "https://www.igorski.nl/download/regrader";
    };
  };

  transformant = mkVst3 {
    source = sources.transformant;
    meta = {
      description = "VST plugin that acts as a multi channel formant filter";
      homepage = "https://www.igorski.nl/download/transformant";
    };
  };

  vstsid = mkVst3 {
    source = sources.vstsid;
    meta = {
      description = "VST plugin version of the WebSID Commodore 64 synthesizer";
      homepage = "https://www.igorski.nl/download/vstsid";
    };
  };
}
