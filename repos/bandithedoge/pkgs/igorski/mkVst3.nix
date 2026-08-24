{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  cairo,
  cmake,
  freetype,
  glib,
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
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  extendDrvArgs =
    finalAttrs:
    {
      meta ? { },
      ...
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

      vst3sdk = stdenv.mkDerivation (finalAttrs: {
        pname = "vst3sdk";
        version = "3.7.11_build_10";
        src = fetchFromGitHub {
          owner = "steinbergmedia";
          repo = "vst3sdk";
          rev = "v${finalAttrs.version}";
          hash = "sha256-DnWdMFT6i7C6jhqEpRHiNkg/WEgs0iLDVJWR2xgMxeM=";
          fetchSubmodules = true;
        };

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
      });
    in
    {
      nativeBuildInputs = [
        cmake
        ninja
        pkg-config
      ];

      buildInputs = commonBuildInputs;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/lib/vst3
        cp -r VST3/Release/${finalAttrs.pname}.vst3 $out/lib/vst3

        runHook postInstall
      '';

      cmakeFlags = [
        "-DVST3_SDK_ROOT=${vst3sdk}"
        "-DSMTG_PLUGIN_TARGET_USER_PATH=${placeholder "out"}"
        "-DSMTG_CREATE_PLUGIN_LINK=OFF"
      ];

      NIX_CFLAGS_COMPILE = [
        "-lpango-1.0"
        "-lpangocairo-1.0"
      ];

      passthru.updateScript = nix-update-script { };

      meta = {
        license = lib.licenses.mit;
        platforms = lib.platforms.linux;
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
}
