{
  lib,
  stdenv,
  fetchgit,
  fetchFromGitHub,
  nim-unwrapped,
  cmake,
  ninja,
  python3,
  git,
  llvmPackages,
  zlib,
  zstd,
}:

stdenv.mkDerivation rec {
  pname = "nlvm";
  version = "a7bb73d";

  src = fetchgit {
    url = "https://github.com/arnetheduck/nlvm.git";
    rev = version;
    hash = "sha256-AAAA1016AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    fetchSubmodules = true;
  };

  checksumsSrc = fetchFromGitHub {
    owner = "nim-lang";
    repo = "checksums";
    rev = "f58b22377f26d30a89bfbbf1d8a412e20464557d";
    hash = "sha256-JDOEWn6jE7husF3Rgz2mH9f9TYeTNzaCQRRWHaX/n9Q=";
  };

  patches = [
    ./0001-Fix-WebAssembly-LLVM-IR-generation-segfault.patch
    ./0002-Fix-genMain-nil-sym-dereference.patch
  ];

  dontUseCmakeConfigure = true;

  nativeBuildInputs = [
    nim-unwrapped
    cmake
    ninja
    python3
    git
    llvmPackages.clang
    llvmPackages.lld
  ];

  # zlib/zstd are needed by the static LLVM link; system llvm_18 is NOT listed
  # here since nlvm links against its own locally-built static LLVM (llvm/sta/).
  buildInputs = [
    zlib
    zstd
  ];

  buildPhase = ''
    runHook preBuild

    # Fix checksums dependency missing in the nim submodule
    mkdir -p lib/nim/dist/checksums
    cp -a ${checksumsSrc}/* lib/nim/dist/checksums/

    # We must build LLVM to satisfy nlvm's llgen/llplatform/lllink.nim dependencies.
    # Use the static path (sta/) matching the Makefile's CI/release build:
    # targets: clang-libraries lld-libraries llvm-libraries llvm-config
    patchShebangs make-llvm.sh
    # libz / libzstd / libstdc++ must be visible for the freshly-built llvm-min-tblgen
    export LD_LIBRARY_PATH="${zlib.out}/lib:${zstd.out}/lib:$(cat $NIX_CC/nix-support/orig-libc)/lib:${stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"
    ./make-llvm.sh sta \
      "clang-libraries lld-libraries llvm-libraries llvm-config" \
      -DLLVM_BUILD_LLVM_DYLIB=0 \
      -DLLVM_LINK_LLVM_DYLIB=0 \
      -DLIBCLANG_BUILD_STATIC=On \
      -DLLVM_ENABLE_ASSERTIONS=0 \
      "-DCMAKE_BUILD_TYPE=Release"

    # Build nlvm using the static LLVM (sta/) so no runtime .so is needed
    export HOME="$TMPDIR"
    export XDG_CACHE_HOME="$TMPDIR/.cache"
    export XDG_CONFIG_HOME="$TMPDIR/.config"
    # clang headers required by nlvm at runtime
    rm -rf lib/clang
    cp -ar llvm/sta/lib/clang lib/
    nim c -d:release -d:staticLLVM --nimcache:nimcache nlvm/nlvm.nim

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib
    cp -a nlvm/nlvm $out/bin/
    cp -ar lib/nim $out/lib/
    cp -ar lib/nlvm $out/lib/
    # ship clang builtins headers so nlvm can find them at runtime
    cp -ar lib/clang $out/lib/
    runHook postInstall
  '';

  meta = {
    description = "LLVM-based Nim compiler with wasm32 support";
    homepage = "https://github.com/arnetheduck/nlvm";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "nlvm";
  };
}
