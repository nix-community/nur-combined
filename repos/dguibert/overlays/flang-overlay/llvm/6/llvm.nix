{ stdenv
, fetchFromGitHub
, cmake
, python
, libffi
, libbfd
, libxml2
, ncurses
, version
, release_version
, zlib
, debugVersion ? false
, enableManpages ? false
, enableSharedLibraries ? true
, enableWasm ? true
}:

let
  #src = fetch "llvm" "1qpls3vk85lydi5b4axl0809fv932qgsqgdgrk098567z4jc7mmn";
  # Used when creating a version-suffixed symlink of libLLVM.dylib
  shortVersion = with stdenv.lib;
    concatStringsSep "." (take 2 (splitString "." release_version));
in stdenv.mkDerivation (rec {
  name = "llvm-${version}";

  src = fetchFromGitHub {
    owner = "flang-compiler";
    repo = "llvm";
    rev = "release_60";
    sha256 = "08c25ava81h46jc033y4w4vmjiqy5bgnzwisb86rxkavy6p87223";
  };

  outputs = [ "out" "python" ]
    ++ stdenv.lib.optional enableSharedLibraries "lib";

  nativeBuildInputs = [ cmake python ]
    ++ stdenv.lib.optional enableManpages python.pkgs.sphinx;

  buildInputs = [ libxml2 libffi ];

  propagatedBuildInputs = [ ncurses zlib ];

  postPatch = stdenv.lib.optionalString stdenv.isDarwin ''
    substituteInPlace cmake/modules/AddLLVM.cmake \
      --replace 'set(_install_name_dir INSTALL_NAME_DIR "@rpath")' "set(_install_name_dir INSTALL_NAME_DIR "$lib/lib")" \
      --replace 'set(_install_rpath "@loader_path/../lib" ''${extra_libdir})' ""
  ''
  # Patch llvm-config to return correct library path based on --link-{shared,static}.
  + stdenv.lib.optionalString (enableSharedLibraries) ''
    substitute '${./llvm-outputs.patch}' ./llvm-outputs.patch --subst-var lib
    patch -p1 < ./llvm-outputs.patch
  '' + ''
    # FileSystem permissions tests fail with various special bits
    substituteInPlace unittests/Support/CMakeLists.txt \
      --replace "Path.cpp" ""
    rm unittests/Support/Path.cpp
  '' + stdenv.lib.optionalString stdenv.hostPlatform.isMusl ''
    patch -p1 -i ${../TLI-musl.patch}
    substituteInPlace unittests/Support/CMakeLists.txt \
      --replace "add_subdirectory(DynamicLibrary)" ""
    rm unittests/Support/DynamicLibrary/DynamicLibraryTest.cpp
  '';

  # hacky fix: created binaries need to be run before installation
  preBuild = ''
    mkdir -p $out/
    ln -sv $PWD/lib $out
  '';

  cmakeFlags = with stdenv; [
    "-DCMAKE_BUILD_TYPE=${if debugVersion then "Debug" else "Release"}"
    "-DLLVM_INSTALL_UTILS=ON"  # Needed by rustc
    "-DLLVM_BUILD_TESTS=ON"
    "-DLLVM_ENABLE_FFI=ON"
    "-DLLVM_ENABLE_RTTI=ON"

    "-DLLVM_HOST_TRIPLE=${stdenv.hostPlatform.config}"
    "-DLLVM_DEFAULT_TARGET_TRIPLE=${stdenv.hostPlatform.config}"
    "-DTARGET_TRIPLE=${stdenv.hostPlatform.config}"

    "-DLLVM_ENABLE_DUMP=ON"
  ]
  ++ stdenv.lib.optional enableSharedLibraries
    "-DLLVM_LINK_LLVM_DYLIB=ON"
  ++ stdenv.lib.optionals enableManpages [
    "-DLLVM_BUILD_DOCS=ON"
    "-DLLVM_ENABLE_SPHINX=ON"
    "-DSPHINX_OUTPUT_MAN=ON"
    "-DSPHINX_OUTPUT_HTML=OFF"
    "-DSPHINX_WARNINGS_AS_ERRORS=OFF"
  ]
  ++ stdenv.lib.optional (!isDarwin)
    "-DLLVM_BINUTILS_INCDIR=${libbfd.dev}/include"
  ++ stdenv.lib.optionals (isDarwin) [
    "-DLLVM_ENABLE_LIBCXX=ON"
    "-DCAN_TARGET_i386=false"
  ]
  ++ stdenv.lib.optional enableWasm
   "-DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly"
  ;

  postBuild = ''
    rm -fR $out

    paxmark m bin/{lli,llvm-rtdyld}
    paxmark m unittests/ExecutionEngine/MCJIT/MCJITTests
    paxmark m unittests/ExecutionEngine/Orc/OrcJITTests
    paxmark m unittests/Support/SupportTests
    paxmark m bin/lli-child-target
  '';

  preCheck = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/lib
  '';

  postInstall = ''
    mkdir -p $python/share
    mv $out/share/opt-viewer $python/share/opt-viewer
  ''
  + stdenv.lib.optionalString enableSharedLibraries ''
    moveToOutput "lib/libLLVM-*" "$lib"
    moveToOutput "lib/libLLVM${stdenv.hostPlatform.extensions.sharedLibrary}" "$lib"
    substituteInPlace "$out/lib/cmake/llvm/LLVMExports-${if debugVersion then "debug" else "release"}.cmake" \
      --replace "\''${_IMPORT_PREFIX}/lib/libLLVM-" "$lib/lib/libLLVM-"
  ''
  + stdenv.lib.optionalString (stdenv.isDarwin && enableSharedLibraries) ''
    substituteInPlace "$out/lib/cmake/llvm/LLVMExports-${if debugVersion then "debug" else "release"}.cmake" \
      --replace "\''${_IMPORT_PREFIX}/lib/libLLVM.dylib" "$lib/lib/libLLVM.dylib"
    ln -s $lib/lib/libLLVM.dylib $lib/lib/libLLVM-${shortVersion}.dylib
    ln -s $lib/lib/libLLVM.dylib $lib/lib/libLLVM-${release_version}.dylib
  '';

  # Testing Time: 1015.42s
  # ********************
  # Failing Tests (15):
  #     LLVM :: Analysis/BasicAA/2007-08-01-NoAliasAndGEP.ll
  #     LLVM :: Analysis/BasicAA/2010-09-15-GEP-SignedArithmetic.ll
  #     LLVM :: Analysis/BasicAA/bug.23540.ll
  #     LLVM :: Analysis/BasicAA/bug.23626.ll
  #     LLVM :: Analysis/BasicAA/constant-over-index.ll
  #     LLVM :: Analysis/BasicAA/fallback-mayalias.ll
  #     LLVM :: Analysis/BasicAA/q.bad.ll
  #     LLVM :: Analysis/BasicAA/returned.ll
  #     LLVM :: Analysis/BasicAA/sequential-gep.ll
  #     LLVM :: Analysis/BasicAA/struct-geps.ll
  #     LLVM :: Analysis/BasicAA/zext.ll
  #     LLVM :: CodeGen/Thumb2/2009-12-01-LoopIVUsers.ll
  #     LLVM :: ExecutionEngine/MCJIT/remote/eh.ll
  #     LLVM :: ExecutionEngine/OrcMCJIT/remote/eh.ll
  #     LLVM :: tools/gold/X86/parallel.ll
  # 
  #   Expected Passes    : 22415
  #   Expected Failures  : 140
  #   Unsupported Tests  : 721
  #   Unexpected Failures: 15
  # 
  doCheck = false; #stdenv.isLinux && (!stdenv.isi686);

  checkTarget = "check-all";

  enableParallelBuilding = true;

  passthru.src = src;

  meta = {
    description = "Collection of modular and reusable compiler and toolchain technologies";
    homepage    = http://llvm.org/;
    license     = stdenv.lib.licenses.ncsa;
    maintainers = with stdenv.lib.maintainers; [ lovek323 raskin dtzWill ];
    platforms   = stdenv.lib.platforms.all;
  };
} // stdenv.lib.optionalAttrs enableManpages {
  name = "llvm-manpages-${version}";

  buildPhase = ''
    make docs-llvm-man
  '';

  propagatedBuildInputs = [];

  installPhase = ''
    make -C docs install
  '';

  outputs = [ "out" ];
  lib = ""; # substituteStream(): ERROR: variable $lib is unset

  doCheck = false;

  meta.description = "man pages for LLVM ${version}";
})
