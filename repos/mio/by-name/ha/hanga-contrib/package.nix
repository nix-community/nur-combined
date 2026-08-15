{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  rustPlatform,
  buildGoModule,
  kotlin,
  jdk,
  go,
  tinygo,
  zig,
  python3,
  wasm-tools,
  wabt,
  wit-bindgen,
  guile,
  guile-hoot,
  nlvm,
  llvmPackages,
  patchelf,
  nim,
  nim-unwrapped,
  koka,
}:

let
  kotlinVersion = "2.4.10";

  kotlinStdlibWasmWasi = fetchurl {
    url = "https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib-wasm-wasi/${kotlinVersion}/kotlin-stdlib-wasm-wasi-${kotlinVersion}.klib";
    hash = "sha256-zCXEaVtGb2XNVSB1C465JV4+BO/mchbZmD2Zq2hBn5M=";
  };

  witBindgenKotlin = rustPlatform.buildRustPackage {
    pname = "wit-bindgen-kotlin";
    version = "0-unstable-2026-08-05";
    src = fetchFromGitHub {
      owner = "Kotlin";
      repo = "wit-bindgen";
      rev = "b47a6f8dd399e28c84eb435d272087717d78b18c";
      hash = "sha256-1UKMI7dtJfjwdaTt0Gkl5fePH19fha1RWpCBVpok++U=";
    };
    cargoHash = "sha256-UrwzUcAJWGNo68d8toYgJbvOB5p5iABARwNpubh7n40=";
    doCheck = false;
    meta = {
      description = "WIT bindgen with the experimental Kotlin/Wasm generator";
      homepage = "https://github.com/Kotlin/wit-bindgen";
      license = lib.licenses.asl20;
      mainProgram = "wit-bindgen";
    };
  };

  goModulesSrc = fetchFromGitHub {
    owner = "bytecodealliance";
    repo = "go-modules";
    rev = "v0.7.0";
    hash = "sha256-bzsB0EsDNk6x1xroIQqbUy7L97JbEJHo7wASnl35X+0=";
  };

  witBindgenGo = buildGoModule {
    pname = "wit-bindgen-go";
    version = "0.7.0";
    src = goModulesSrc;
    vendorHash = "sha256-R4BdPlcaQBhH3cpLq//aeS3F2Qe4Z/TV/TALs6OSnAQ=";
    env.GOWORK = "off";
    subPackages = [ "cmd/wit-bindgen-go" ];
    doCheck = false;
    meta = {
      description = "WIT bindgen for Go guests";
      homepage = "https://github.com/bytecodealliance/go-modules";
      license = lib.licenses.asl20;
      mainProgram = "wit-bindgen-go";
    };
  };
in
stdenv.mkDerivation {
  pname = "hanga-contrib";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [
    kotlin
    jdk
    go
    tinygo
    zig
    python3
    wasm-tools
    wabt
    witBindgenKotlin
    witBindgenGo
    wit-bindgen
    guile
    guile-hoot
    nim
    koka
  ]
  ++ lib.optionals (stdenv.buildPlatform.system == "x86_64-linux") [
    nlvm
    llvmPackages.clang
    llvmPackages.lld
    patchelf
  ];

  env.JAVA_HOME = jdk;

  buildPhase = ''
    runHook preBuild

    kotlinc-jvm \
      -cp ${kotlin}/lib/kotlin-stdlib.jar \
      -include-runtime \
      -d kit-test.jar \
      lib/hanga/mod/Kit.kt \
      lib/hanga/mod/Catalog.kt \
      lib/hanga/mod/Wire.kt \
      lib/hanga/mod/KitTest.kt
    ${jdk}/bin/java -jar kit-test.jar

    export HOME="$TMPDIR"
    export GOCACHE="$TMPDIR/go-cache"
    export GOMODCACHE="$TMPDIR/gomod"
    go test -C lib/go/hangamod .

    export ZIG_GLOBAL_CACHE_DIR="$TMPDIR/zig-cache"
    zig test lib/zig/hangamod/root.zig

    export GUILE_AUTO_COMPILE=0
    export XDG_CACHE_HOME="$TMPDIR/xdg-cache"
    guile -L lib/scheme --r7rs -s lib/scheme/hangamod/test.scm
    hoot compile -L lib/scheme --run lib/scheme/hangamod/test.scm

    mkdir -p wit bindings klib out
    cp -a ${../hanga/wit}/. wit/
    ${witBindgenKotlin}/bin/wit-bindgen kotlin --kotlin-imports 'impl.*' wit --out-dir bindings

    kotlinc-wasm -Xwasm-target=wasm-wasi \
      -ir-output-dir klib/lab_tile.klib -ir-output-name lab_tile \
      -libraries ${kotlinStdlibWasmWasi} \
      -kotlin-home ${kotlin} \
      -main noCall \
      lib/hanga/mod/Kit.kt \
      lib/hanga/mod/Catalog.kt \
      lib/hanga/mod/Wire.kt \
      examples/lab-tile/src/impl/Gameplay.kt \
      $(find bindings -name '*.kt')

    kotlinc-wasm -Xwasm-target=wasm-wasi -Xir-produce-js \
      -Xwasm-use-traps-instead-of-exceptions \
      -Xinclude=klib/lab_tile.klib \
      -ir-output-dir out -ir-output-name lab_tile \
      -libraries ${kotlinStdlibWasmWasi} \
      -kotlin-home ${kotlin} \
      -main noCall

    wat2wasm wasi_random_stub.wat -o wasi_random_stub.wasm
    wasm-tools component embed wit out/lab_tile.wasm -o lab_tile.embedded.wasm
    wasm-tools component new lab_tile.embedded.wasm \
      --adapt wasi_snapshot_preview1=wasi_random_stub.wasm \
      -o lab_tile.wasm

    export GOPROXY=off
    export GOSUMDB=off
    wasm-tools component wit -j --all-features wit > wit.json
    (
      cd examples/lab-slab
      printf '\nreplace go.bytecodealliance.org/cm => ${goModulesSrc}/cm\n' >> go.mod
      wit-bindgen-go generate --world plugin --out gen ../../wit.json
      tinygo build -target=wasi -scheduler=none -gc=leaking -o lab_slab.core.wasm .
    )
    wasm-tools print examples/lab-slab/lab_slab.core.wasm > lab_slab.core.wat
    python3 scripts/patch-cabi-realloc.py lab_slab.core.wat lab_slab.cabi.wat
    wasm-tools parse lab_slab.cabi.wat -o lab_slab.cabi.wasm
    wat2wasm wasi_p1_stub.wat -o wasi_p1_stub.wasm
    wasm-tools component embed wit lab_slab.cabi.wasm -o lab_slab.embedded.wasm
    wasm-tools component new lab_slab.embedded.wasm \
      --adapt wasi_snapshot_preview1=wasi_p1_stub.wasm \
      -o lab_slab.wasm

    mkdir -p zig-c
    ${wit-bindgen}/bin/wit-bindgen c --world plugin --out-dir zig-c wit
    cp -a lib/zig/hangamod examples/lab-grid/hangamod
    zig build-exe examples/lab-grid/main.zig lib/c/hangamod/payload.c zig-c/plugin.c zig-c/plugin_component_type.o \
      -target wasm32-wasi-musl -O ReleaseSmall -fno-entry -rdynamic -lc \
      -I zig-c -I lib/c/hangamod -femit-bin=lab_grid.core.wasm
    wasm-tools component embed wit lab_grid.core.wasm -o lab_grid.embedded.wasm
    wasm-tools component new lab_grid.embedded.wasm \
      --adapt wasi_snapshot_preview1=wasi_p1_stub.wasm \
      -o lab_grid.wasm

    hoot compile -L lib/scheme --mode=standalone \
      -o lab_owl.wasm examples/lab-owl/main.scm

    ${lib.optionalString (stdenv.buildPlatform.system == "x86_64-linux") ''
      nlvm c --path:lib/nim/hangamod --outdir:"$TMPDIR/nlvm-test" \
        --passl:-L${stdenv.cc.libc.out}/lib \
        --passl:-L${stdenv.cc.cc.lib}/lib \
        lib/nim/hangamod/test.nim
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        "$TMPDIR/nlvm-test/test"
      "$TMPDIR/nlvm-test/test"
    ''}

    # nlvm --cpu:wasm32 SIGSEGVs on the continuous Linux tarball (llgen).
    # Nim C backend + the same wit-bindgen C objects as Zig produces the component.
    nim c --cpu:wasm32 --os:standalone --mm:none --noMain --threads:off \
      --compileOnly --nimcache:nimcache examples/lab-nim/main.nim
    zig build-exe lib/c/hangamod/payload.c zig-c/plugin.c zig-c/plugin_component_type.o \
      $(find nimcache -name '*.c') \
      -target wasm32-wasi-musl -O ReleaseSmall -fno-entry -rdynamic -lc \
      -I zig-c -I lib/c/hangamod -I ${nim-unwrapped}/nim/lib -femit-bin=lab_nim.core.wasm
    wasm-tools component embed wit lab_nim.core.wasm -o lab_nim.embedded.wasm
    wasm-tools component new lab_nim.embedded.wasm \
      --adapt wasi_snapshot_preview1=wasi_p1_stub.wasm \
      -o lab_nim.wasm

    koka -e --builddir="$TMPDIR/koka-test" --include=lib/koka lib/koka/hangamod/test.kk
    (
      cd examples/lab-koka
      koka -c --library --target=c32 --builddir="$TMPDIR/koka-mod" \
        --ccopts=-Wno-implicit-function-declaration \
        labkoka.kk
    )
    KOKAC=$(find "$TMPDIR/koka-mod" -name labkoka.c -printf '%h\n' | head -n 1)
    KKLIB=$(echo ${koka}/share/koka/v*/kklib)
    zig cc "$KKLIB/src/all.c" \
      examples/lab-koka/wasi-stubs.c \
      lib/c/hangamod/payload.c \
      examples/lab-koka/guest.c \
      zig-c/plugin.c zig-c/plugin_component_type.o \
      $(find "$KOKAC" -name '*.c') \
      -I "$KKLIB/include" -I "$KOKAC" -I zig-c -I lib/c/hangamod \
      -include examples/lab-koka/wasi-posix.h \
      -Wno-#pragma-messages \
      -DKK_STATIC_LIB=1 -DKK_COMP_VERSION='"3.2.3"' \
      -D_WASI_EMULATED_SIGNAL \
      -target wasm32-wasi-musl -O2 -Wl,--no-entry -Wl,--export-dynamic \
      -lc -lwasi-emulated-signal \
      -o lab_koka.core.wasm
    wat2wasm wasi_p1_koka_stub.wat -o wasi_p1_koka_stub.wasm
    wasm-tools component embed wit lab_koka.core.wasm -o lab_koka.embedded.wasm
    wasm-tools component new lab_koka.embedded.wasm \
      --adapt wasi_snapshot_preview1=wasi_p1_koka_stub.wasm \
      -o lab_koka.wasm

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/hanga/mods $out/share/hanga/games $out/share/hanga/hoot $out/share/hanga-contrib
    cp lab_tile.wasm $out/share/hanga/mods/lab_tile.wasm
    cp lab_slab.wasm $out/share/hanga/mods/lab_slab.wasm
    cp lab_grid.wasm $out/share/hanga/mods/lab_grid.wasm
    cp lab_nim.wasm $out/share/hanga/mods/lab_nim.wasm
    cp lab_koka.wasm $out/share/hanga/mods/lab_koka.wasm
    cp lab_owl.wasm $out/share/hanga/hoot/lab_owl.wasm
    cp -a games/. $out/share/hanga/games/
    rm -f $out/share/hanga/games/lab_owl.game
    cp -a lib $out/share/hanga-contrib/lib
    cp README.md $out/share/hanga-contrib/
    runHook postInstall
  '';

  meta = {
    description = "Hanga contrib mods: Kotlin, TinyGo, Zig, nlvm/Nim, Koka, and Hoot examples";
    license = lib.licenses.mit;
  };
}
