{
  lib,
  fetchFromGitHub,
  stdenv,
  gmp,
  libffi,
  sdl3,
  mlton,
  pkg-config,
  versionCheckHook,
  nix-update-script,
  # The checked-in SDL bindings are generated for Linux/x86-64 only.
  withSdl ? stdenv.hostPlatform.isx86_64,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rune";
  version = "0.1-unstable-2026-10-26";

  src = fetchFromGitHub {
    owner = "ruudkoot";
    repo = "rune";
    rev = "9d256dcf8d7980637a15208296cfa6325afb6c20";
    hash = "sha256-Vq2fZRBkHKQXOnizmEU7qBqW3WfnDvXe0uSXlNBFOVo=";
  };

  preBuild = ''
    mkdir -p build
    printf 'structure Config =\nstruct\n  val version = "%s"\n  val identity = ""\nend\n' \
      ${finalAttrs.version} > build/config.sml
    printf '#define RUNE_VERSION "%s"\n' ${finalAttrs.version} > runtime/version.h
  '';

  buildFlags = [
    "all"
    "repl"
    "kernel"
    "dap"
    "lsp"
    "heapsim"
  ];

  makeFlags = [
    "MLTON=${lib.getExe' mlton "mlton"}"
    "GMP=yes"
    "FFI=yes"
    "DOCTOR=no"
    "JOBS=$(NIX_BUILD_CORES)"
  ];

  nativeBuildInputs = [
    mlton
    pkg-config
  ];

  buildInputs = [
    gmp
    libffi
  ];

  # SDL is opened at run time from paths the program is given, together with
  # an adapter library compiled from the generated set's shims.c.
  postBuild = lib.optionalString withSdl ''
    for set in lib/ffi/sdl/generated/native/sets/*; do
      $CC -shared -fPIC -DSDL_MAIN_HANDLED=1 -Iffi/sdl/upstream \
        -o $set/shims.so $set/shims.c
    done
  '';

  installPhase = ''
    runHook preInstall

    sh scripts/install.sh --prefix $out
    install -Dm755 -t $out/bin bin/heapsim bin/heapsim-gen bin/gcsim

    # install.sh leaves out the language server. It starts its analysis
    # workers with the runevm beside its own bytecode.
    install -Dm644 -t $out/lib/rune bin/runelsp.rbc
    ln -s ../../bin/runevm $out/lib/rune/runevm
    cat > $out/bin/runelsp <<EOF
    #!/bin/sh
    exec $out/bin/runevm $out/lib/rune/runelsp.rbc --lib $out/lib/rune "\$@"
    EOF
    chmod 755 $out/bin/runelsp

    # The wrappers find runevm and lib/rune beside themselves with dirname,
    # which is not on PATH at run time.
    for w in rune rune-repl rune-dap rune-kernel runedoc runeopt runeffi; do
      substituteInPlace $out/bin/$w --replace-fail 'd=$(dirname "$0")' "d=$out/bin"
    done
  ''
  + lib.optionalString withSdl ''
    for set in lib/ffi/sdl/generated/native/sets/*; do
      install -Dm755 -t $out/lib/rune/''${set#lib/} $set/shims.so
    done
    ln -s ${lib.getLib sdl3}/lib/libSDL3.so.0 $out/lib/rune/ffi/sdl/libSDL3.so.0
  ''
  + ''

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    homepage = "https://github.com/ruudkoot/rune";
    description = "Compiler and runtime for Standard ML '97";
    license = lib.licenses.cc0;
    mainProgram = "rune";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    badPlatforms = [
      "aarch64-linux"
    ];
  };
})
