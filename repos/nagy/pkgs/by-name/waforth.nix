{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  wabt,
  nodejs,
  wasmtime,
}:

let
  # The compiler, waforthc, requires an older version of wabt.
  wabt1031 = wabt.overrideAttrs {
    src = fetchFromGitHub {
      owner = "WebAssembly";
      repo = "wabt";
      rev = "1.0.31";
      hash = "sha256-EChOQTWGt/LUfwCxmMmYC+zHjW9hVvghhOGr4DfpNtQ=";
      fetchSubmodules = true;
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "waforth";
  version = "0.20.1";

  src = fetchFromGitHub {
    owner = "remko";
    repo = "waforth";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xcYnS7eVSME50b8obj7tIg0Nwx7sN2ndleucwAm/YXA=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/nagy/waforth/commit/7a3327b093bc69cfda9704f86f7e7d4e11b7ff18.patch";
      hash = "sha256-0aT2ZQkaRLJVgk8C2iQENgJaVQ0tLStbrC74CfATpAc=";
    })
  ];

  postPatch = ''
    patchShebangs src/standalone/../../scripts/bin2h
  '';

  nativeBuildInputs = [
    wabt1031
    nodejs
  ];

  makeFlags = [
    "WASMTIME_DIR=${lib.getDev wasmtime}"
    "WABT_DIR=${wabt1031}"
    "standalone"
    "waforthc"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin src/standalone/waforth src/waforthc/waforthc
    install -Dm644 src/standalone/waforth_core.wasm $out/share/waforth/waforth.wasm
    runHook postInstall
  '';

  meta = {
    description = "Small but complete dynamic Forth Interpreter/Compiler for and in WebAssembly";
    homepage = "https://github.com/remko/waforth";
    license = with lib.licenses; [ mit ];
  };
})
