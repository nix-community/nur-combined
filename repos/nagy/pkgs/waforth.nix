{ lib, stdenv, fetchFromGitHub, wabt, nodejs, wasmtime }:

let
  # the compiler, waforthc, requires an older version of wabt.
  wabt1031 = wabt.overrideAttrs (old: {
    src = fetchFromGitHub {
      owner = "WebAssembly";
      repo = "wabt";
      rev = "1.0.31";
      hash = "sha256-EChOQTWGt/LUfwCxmMmYC+zHjW9hVvghhOGr4DfpNtQ=";
      fetchSubmodules = true;
    };
  });
in stdenv.mkDerivation rec {
  pname = "waforth";
  version = "0.19.1";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "waforth";
    rev = "7a3327b093bc69cfda9704f86f7e7d4e11b7ff18";
    hash = "sha256-AxdVIV7nWRtHdqI0cBPvAhiOqKqn3uYdlh6dLK9Uaj8=";
  };

  postPatch = ''
    patchShebangs src/standalone/../../scripts/bin2h
  '';

  nativeBuildInputs = [ wabt1031 nodejs ];

  makeFlags = [
    "WASMTIME_DIR=${lib.getDev wasmtime}"
    "WABT_DIR=${wabt1031}"
    "standalone"
    "waforthc"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm555 -t $out/bin src/standalone/waforth src/waforthc/waforthc
    install -Dm444 src/standalone/waforth_core.wasm $out/share/waforth/waforth.wasm
    runHook postInstall
  '';

  meta = with lib; {
    description = "Small but complete dynamic Forth Interpreter/Compiler for and in WebAssembly";
    inherit (src.meta) homepage;
    license = with licenses; [ mit ];
  };
}
