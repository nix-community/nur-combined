{
  sources,
  stdenvNoCC,
  lib,
  clang,
  rustc,
  cargo,
  lld,
  nodejs,
  python3,
  jre,
  closurecompiler,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (sources.v86) pname version src;
  postPatch = ''
    patchShebangs --build gen/*.js tools/*
  '';

  makeFlags = [
    "CLOSURE=${closurecompiler}/share/java/closure-compiler-v${closurecompiler.version}.jar"
    # targets
    "build/libv86.mjs"
    "build/v86.wasm"
    # the two js files can not be built properly with latest closure compiler
    # so I simply ignore them and build the mjs file only
  ];

  nativeBuildInputs = [
    clang.cc # use wrapped clang
    jre
    nodejs
    rustc
    cargo
    python3
    lld
  ];

  installPhase = ''
    runHook preInstall
    mkdir --parents "$out"
    install --mode=644 -t "$out" build/libv86.mjs build/v86.wasm
    runHook postInstall
  '';

  meta = with lib; {
    description = "x86 PC emulator and x86-to-wasm JIT, running in the browser";
    homepage = "https://copy.sh/v86";
    maintainers = with maintainers; [ yinfeng ];
  };
})
