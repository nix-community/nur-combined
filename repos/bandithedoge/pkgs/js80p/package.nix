{
  sources,

  stdenv,
  lib,

  cairo,
  cppcheck,
  libx11,
  libxcb,
  symlinkJoin,

  instructionSet ? "avx", # sse2 or avx
}:
let
  arch = stdenv.targetPlatform.uname.processor;
in
stdenv.mkDerivation rec {
  inherit (sources.js80p) pname src;
  version = lib.removePrefix "v" sources.js80p.version;

  buildInputs = [
    cairo
    libx11
    libxcb
  ];

  postPatch = ''
    substituteInPlace make/linux-gpp.mk \
      --replace-fail "/usr/bin/objcopy" "${stdenv.cc}/bin/objcopy"
  '';

  buildPhase = ''
    runHook preBuild

    make all

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/{vst,vst3}

    cp dist/js80p-dev-linux-${arch}-${instructionSet}-fst/js80p.so $out/lib/vst
    cp dist/js80p.vstxml $out/lib/vst

    mkdir -p $out/lib/vst3/js80p.vst3/Contents/${stdenv.system}
    cp dist/js80p-dev-linux-${arch}-${instructionSet}-vst3_single/js80p.vst3 \
      $out/lib/vst3/js80p.vst3/Contents/${stdenv.system}/js80p.so

    runHook postInstall
  '';

  SYS_LIB_PATH =
    (symlinkJoin {
      name = "js80p-libs";
      paths = [
        cairo
        libxcb
      ];
    })
    + "/lib";

  CPPCHECK = cppcheck + "/bin/cppcheck";
  CPP_DEV_PLATFORM = stdenv.cc + "/bin/c++";
  CPP_TARGET_PLATFORM = stdenv.cc + "/bin/c++";
  INSTRUCTION_SET = instructionSet;
  TARGET_PLATFORM = "${arch}-gpp";
  VERSION_STR = version;
  VERSION_INT = lib.concatStrings (lib.splitString "." (lib.removePrefix "v" version));

  hardeningDisable = [ "format" ];
  NIX_CFLAGS_COMPILE = [ "-Wno-error" ];

  enableParallelBuilding = true;

  meta = {
    description = "A MIDI driven, performance oriented, versatile, free and open source synthesizer VST plugin";
    homepage = "https://attilammagyar.github.io/js80p/index.html#home";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
