{
  instructionSet ? "avx", # sse2 or avx

  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  cairo,
  cppcheck,
  libx11,
  libxcb,
  symlinkJoin,
}:
let
  arch = stdenv.targetPlatform.uname.processor;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "js80p";
  version = "4.1.1";
  src = fetchFromGitHub {
    owner = "attilammagyar";
    repo = "js80p";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wFhkwRyxul+mr9GsL+coNFQWu6z4x+Cxm7BUpUujiwk=";
  };

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
  VERSION_STR = finalAttrs.version;
  VERSION_INT = lib.concatStrings (lib.splitString "." finalAttrs.version);

  hardeningDisable = [ "format" ];
  NIX_CFLAGS_COMPILE = [ "-Wno-error" ];

  enableParallelBuilding = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A MIDI driven, performance oriented, versatile, free and open source synthesizer VST plugin";
    homepage = "https://attilammagyar.github.io/js80p/index.html#home";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
