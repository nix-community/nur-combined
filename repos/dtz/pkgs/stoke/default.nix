{ stdenv, fetchFromGitHub
, bison
, binutils
, boost
, cln
, cmake
, doxygen
, flex
, ghcWithPackages
, git
, jsoncpp
, python
# Not mentioned deps
, gmp
, iml
# Kludge for source
, astyle
# Fixed platform to build for
, stokePlatform ? "sandybridge"
, debugVersion ? false
, makeWrapper
, patchelf
}:

let
  ghc = ghcWithPackages (pkgs: with pkgs; [
    regex-compat regex-tdfa split
  ]);
  buildCfg = if debugVersion then "debug" else "release";

in stdenv.mkDerivation rec {
  version = "2016-03-11";
  name = "stoke-${stokePlatform}-${version}";

  src = fetchFromGitHub {
    owner = "StanfordPL";
    repo = "stoke";
    rev = "6f771917bfcf12667ac62ade3befd77cd6b40e93";
    sha256 = "1vdkci88bdldw3max0mj1v1xgadqiqm84w80xs37mcsjcqjpmbbx";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    bison flex
    makeWrapper
    cmake
    doxygen
    git
    patchelf
  ];
  buildInputs = [
    cln
    ghc
    gmp
    iml
    boost
    jsoncpp
    python
  ];

  postUnpack = ''
    unpackFile ${astyle.src}
    mv astyle source/src/ext/astyle
  '';

  patchPhase = ''
    patchShebangs configure.sh
    patchShebangs src/validator/generate_handlers_h.sh
    :> scripts/make/submodule-init.sh

    substituteInPlace Makefile --replace ccache ""
    substituteInPlace src/ext/x64asm/Makefile --replace ccache ""

    # Build x86asm using the specified "EXT_OPT" option, otherwise goes unused
    substituteInPlace src/ext/x64asm/Makefile --replace 'all: release' 'all: $(EXT_OPT)'

    substituteInPlace src/validator/null.cc \
      --replace '#include "gmp.h"' '#include <gmp.h>' \
      --replace '#include "iml.h"' '#include <iml.h>'

    sed -i 's,make$,$(MAKE) -j$(NTHREADS),' Makefile

    echo OBJDUMP=$OBJDUMP
    echo "$(command -v $OBJDUMP)"
    substituteInPlace src/disassembler/disassembler.cc \
      --replace "/usr/bin/objdump" "$(command -v $OBJDUMP)"

    sed -i "s,pin_path = .*,pin_path = \"$out/libexec/stoke/pin/\";," tools/apps/stoke_testcase.cc
    substituteInPlace tools/apps/stoke_testcase.cc \
      --replace "pin_path <<" "here <<"
  '';

  configurePhase = ''
    cat > .stoke_config <<EOF
    STOKE_PLATFORM="${stokePlatform}"
    BUILD_TYPE=${buildCfg}
    MISC_OPTIONS=
    EOF
  '';

  buildPhase = ''
    make -C src/ext/astyle/build/gcc -j$NIX_BUILD_CORES -l$NIX_BUILD_CORES
    make ${buildCfg} NTHREADS=$NIX_BUILD_CORES -l$NIX_BUILD_CORES -j1
  '';

  # No one writes install targets :(
  installPhase = ''
    mkdir -p $out/{bin,lib}

    # XXX: Copy bin/strata_programs ??
    cp -r bin/* $out/bin/

    cp -prd src/ext/cvc4-1.4-build/lib/libcvc4.so* $out/lib/
    cp -prd src/ext/z3/build/libz3.so $out/lib/

    mkdir -p $out/libexec/stoke/
    cp -r src/ext/pin-2.13-62732-gcc.4.4.7-linux/ $out/libexec/stoke/pin

    export PIN_ROOT="$out/libexec/stoke/pin"

    makeWrapper $PIN_ROOT/pin $out/bin/pin \
      --set PIN_ROOT $PIN_ROOT \
      --prefix PATH ':' $PIN_ROOT \
      --prefix LD_LIBRARY_PATH ':' $PIN_ROOT/intel64/runtime

    for x in $PIN_ROOT/intel64/bin/*; do
     patchelf --debug --set-interpreter ${stdenv.cc.libc.out}/lib/ld-*so.? $x
    done
    patchelf --debug --set-interpreter ${stdenv.cc.libc.out}/lib/32/ld-*so.? $PIN_ROOT/pin
  '';
    ## for x in $PIN_ROOT/ia32/bin/*; do
    ##   patchelf --debug --set-interpreter ${stdenv.cc.libc.out}/lib/32/ld-*so.? $x
    ## done

  dontPatchELF = true;
  dontStrip = true;

  # separateDebugInfo = true;

  passthru.stokePlatform = stokePlatform;

  meta = with stdenv.lib; {
    description = "Stochastic superoptimizer and program synthesizer";
    homepage = http://stoke.stanford.edu/;
    license = licenses.unfree; # XXX ?
    maintainers = with maintainers; [ dtzWill ];
  };
}
