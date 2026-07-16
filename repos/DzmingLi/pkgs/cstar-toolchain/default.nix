{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  lndir,
  wrapCCWith,
  glibc,
  coreutils,
  z3,
  zlib,
}:

let
  version = "0.5.0";
  clangVersion = "20.1.8";
  clangResourceVersion = lib.versions.major clangVersion;

  # Keep the complete upstream layout: cstarc resolves cst_clang, the proof
  # runtime, its headers, and hol_light_server relative to CSTAR_HOME.
  unwrapped = stdenvNoCC.mkDerivation {
    pname = "cstar-toolchain-unwrapped";
    inherit version;

    src = fetchurl {
      url = "https://gitee.com/cstarlang/cstar_docs/releases/download/v${version}/cstar_linux-x64.tar.xz";
      hash = "sha256-JWSga5QrD+UuyeGOI6UQoIHqPpiwpJxlnDdOD7yzrfo=";
    };

    sourceRoot = "cstar_v${version}_linux-x64";

    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [
      glibc
      stdenv.cc.cc.lib
    ];

    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -R bin include lib "$out/"

      runHook postInstall
    '';
  };

  # Present the CStar LLVM fork in the conventional shape expected by
  # Nixpkgs' compiler wrapper.  The wrapper supplies the libc headers, crt
  # objects, linker, GCC runtimes, and the Nix dynamic loader explicitly.
  cstarClangUnwrapped = stdenvNoCC.mkDerivation {
    pname = "cstar-clang-unwrapped";
    version = clangVersion;

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p "$out/bin" "$out/lib/clang/${clangResourceVersion}"
      ln -s ${unwrapped}/bin/cst_clang "$out/bin/clang"
      ln -s ${unwrapped}/bin/cst_clang "$out/bin/clang++"
      ln -s ${unwrapped}/lib/clang/${clangResourceVersion}/include \
        "$out/lib/clang/${clangResourceVersion}/include"
    '';

    passthru = {
      isClang = true;
      langC = true;
      langCC = true;
    };
  };

  cstarClang = wrapCCWith {
    cc = cstarClangUnwrapped;
    bintools = stdenv.cc.bintools;
    libc = glibc;
    isClang = true;
    gccForLibs = stdenv.cc.cc;

    extraBuildCommands = ''
      mkdir -p "$out/resource-root"
      ln -s ${unwrapped}/lib/clang/${clangResourceVersion}/include \
        "$out/resource-root/include"
      echo "-resource-dir=$out/resource-root" >> "$out/nix-support/cc-cflags"
    '';

    # CStar projects commonly use Z3, while the proof runtime may use zlib.
    # These flags belong to the compiler wrapper because cstarc invokes the
    # compiler after the Nix build has finished, outside a stdenv shell.
    nixSupport = {
      cc-cflags = [
        "-isystem"
        "${lib.getDev z3}/include"
        "-isystem"
        "${lib.getDev zlib}/include"
      ];
      cc-ldflags = [
        "-L${lib.getLib z3}/lib"
        "-rpath"
        "${lib.getLib z3}/lib"
        "-L${lib.getLib zlib}/lib"
        "-rpath"
        "${lib.getLib zlib}/lib"
        "-rpath"
        "${unwrapped}/lib"
      ];
    };
  };

  systemIncludePath = lib.makeSearchPathOutput "dev" "include" [
    glibc
    z3
    zlib
  ];

  # Upstream defaults its mutable proof cache and theorem/conversion database
  # dumps to the directory containing hol_light_server.  That directory is
  # read-only in the Nix store, so use XDG locations unless the user supplied
  # the native CStar variables explicitly.
  runtimeStateEnvironment = ''
    cstar_home_dir="''${HOME:-''${TMPDIR:-/tmp}}"
    export LCF_PROOF_CACHE="''${LCF_PROOF_CACHE:-''${XDG_CACHE_HOME:-$cstar_home_dir/.cache}/cstar/proof-cache}"
    export LCF_STATE_DIR="''${LCF_STATE_DIR:-''${XDG_STATE_HOME:-$cstar_home_dir/.local/state}/cstar}"
  '';

  runtimeStateSetup = runtimeStateEnvironment + ''
    ${lib.getExe' coreutils "mkdir"} -p "$LCF_PROOF_CACHE" "$LCF_STATE_DIR"
  '';
in
stdenvNoCC.mkDerivation {
  pname = "cstar-toolchain";
  inherit version;

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [
    lndir
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    lndir -silent ${unwrapped} "$out"

    # cstarc always uses $CSTAR_HOME/bin/cst_clang, so replace just that
    # entry with the Nixpkgs-wrapped compiler while retaining the rest of the
    # official toolchain layout.
    rm "$out/bin/cst_clang"
    ln -s ${cstarClang}/bin/clang "$out/bin/cst_clang"

    wrapProgram "$out/bin/cstarc" \
      --set CSTAR_HOME "$out" \
      --run ${lib.escapeShellArg runtimeStateEnvironment}
    wrapProgram "$out/bin/cstar_mcp" \
      --set CSTAR_HOME "$out" \
      --set CSTAR_MCP_CSTARC "$out/bin/cstarc" \
      --run ${lib.escapeShellArg runtimeStateEnvironment}
    wrapProgram "$out/bin/hol_light_server" \
      --set CSTAR_HOME "$out" \
      --set LCF_HELP_DIR "$out/bin/help" \
      --run ${lib.escapeShellArg runtimeStateSetup}
    wrapProgram "$out/bin/cst_clangd" \
      --set CSTAR_HOME "$out" \
      --prefix CPATH : ${lib.escapeShellArg systemIncludePath}

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    "$out/bin/cstarc" --version
    "$out/bin/cstar_mcp" --help >/dev/null
    "$out/bin/cst_clang" --version >/dev/null
    "$out/bin/cst_clangd" --version >/dev/null

    workdir="$(mktemp -d)"
    printf '%s\n' \
      '#include <stdio.h>' \
      'int main(void) { puts("cstar-toolchain install check"); return 0; }' \
      > "$workdir/check.c"
    "$out/bin/cst_clang" "$workdir/check.c" -o "$workdir/check"
    "$workdir/check" | grep -F 'cstar-toolchain install check' >/dev/null
    rm -rf "$workdir"

    runHook postInstallCheck
  '';

  passthru = {
    inherit cstarClang unwrapped;
    updateInfo = {
      releasePage = "https://gitee.com/cstarlang/cstar_docs/releases";
      archive = "cstar_linux-x64.tar.xz";
    };
  };

  meta = {
    description = "CStar compiler, verifier, HOL Light server, and language tooling";
    homepage = "https://cstarlang.org";
    downloadPage = "https://gitee.com/cstarlang/cstar_docs/releases";
    # The public binary release contains no license notice for the private
    # compiler sources, so classify it conservatively.
    license = lib.licenses.unfree;
    mainProgram = "cstarc";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
