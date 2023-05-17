{ lib, stdenv, fetchFromGitHub, wabt, which, nodejs, wasmtime }:

stdenv.mkDerivation rec {
  pname = "waforth";
  version = "0.19.1";

  src = fetchFromGitHub {
    owner = "remko";
    repo = "waforth";
    rev = "v${version}";
    sha256 = "sha256-SH4VtmpXjjCkDYbo2dv6WBk7WtoWWo0b0Qt7wkYWP0I=";
  };

  nativeBuildInputs = [ which wabt nodejs wasmtime ];

  makeFlags = [
    "WASMTIME_DIR=${lib.getDev wasmtime}"
    # "WABT_DATA_DIR=${wabt}/share/wabt"
    # "WABT_INCLUDE_DIR=${wabt}/include"
  ];

  postPatch = lib.optionalString (!stdenv.hostPlatform.isStatic) ''
    patchShebangs src/standalone/../../scripts/bin2h
    substituteInPlace src/standalone/Makefile \
      --replace libwasmtime.a libwasmtime.so
  '';

  buildPhase = ''
    runHook preBuild
    make $makeFlags -C src/standalone waforth
    # make $makeFlags -C src/waforthc waforthc   # broken
  '';

  installPhase = ''
    runHook preInstall
    install -Dm555 -t $out/bin src/standalone/waforth
    install -Dm444 src/standalone/waforth_core.wasm $out/share/waforth/waforth.wasm
    runHook postInstall
  '';

  meta = with lib; {
    description = "Small but complete dynamic Forth Interpreter/Compiler for and in WebAssembly";
    inherit (src.meta) homepage;
    license = with licenses; [ mit ];
  };
}
