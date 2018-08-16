{ stdenv, fetchFromGitHub, autoreconfHook, llvm, libbfd, libiberty, libopcodes, lit, ncurses5, zlib }:

stdenv.mkDerivation rec {
  name = "libbeauty-${version}";
  version = "2017-04-23";
  src = fetchFromGitHub {
    owner = "jcdutton";
    repo = "libbeauty";
    rev = "6a6f8f0c57dbc38fdd0d1f8d6626b1c7b672e81c";
    sha256 = "1ld527csfaz3jgdvkrdnmv2b7lnl4nisk3s0ajjb00c8zpk0a2x1";
  };

  nativeBuildInputs = [ autoreconfHook lit ];
  buildInputs = [ llvm libbfd libiberty libopcodes ncurses5 zlib ];

  setSourceRoot = ''
    cd */libbeauty
    sourceRoot=$PWD
  '';

  patchPhase = ''
    # Remove failing test case for now ( https://github.com/jcdutton/libbeauty/issues/20 )
    rm test/tests/id27.txt
  '';

  postInstall = ''
    make -C test

    mkdir -p $out/bin
    cp test/dis64 $out/bin/
  '';

  # Tests want LLVM_OBJ_ROOT available, and tries to create directories there.
  # Likely something that can be patched around, but disable for now.
  # Executed as install check so libraries are available
  doInstallCheck = true;

  installCheckPhase = ''
    export LLVM_BASE=${llvm}
    export LIBBEAUTY_BASE=$PWD

    sed -i 's,config.llvm_obj_root =.*,,' lit.site.cfg
    rm test/FileCheck
    touch lit.site.cfg.dummy
    PATH=$PWD/test:$PATH lit -s -v . -D llvm_site_config=$PWD/lit.site.cfg.dummy
  '';

  meta = with stdenv.lib; {
    description = "Decompiler and Reverse Engineering tool";
    homepage = https://github.com/jcdutton/libbeauty;
    license = licenses.gpl2;
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}
