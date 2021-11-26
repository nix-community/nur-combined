{ stdenv, lib, fetchFromGitHub, cmake }:
let
  asmjit_src = fetchFromGitHub {
    repo   = "asmjit";
    owner  = "asmjit";
    rev    = "70e80b18a5cc05d566e6c90dde200472c9325113";
    sha256 = "0if6npdx1qxvxdlkvnil8lqx3vclx2i2bliyj5xrl1ha0vnffmws";
  };
in
stdenv.mkDerivation {
  pname = "mathpresso";
  version = "git";

  #buildInputs = [ asmjit ];

  nativeBuildInputs = [ cmake ];
  cmakeFlags = [ "-DASMJIT_DIR=${asmjit_src}" ];


  src = fetchFromGitHub {
    repo   = "mathpresso";
    owner  = "kobalicek";
    rev    = "abb3cd67e530aeb09a03beae60f802a4b0f3fd6d";
    sha256 = "1nh173kb1n00z5p11gamnl5lxk8g0lw1l8pncj9gdbvrcyyksaxh";
  };

  installPhase = ''
    mkdir -p $out/lib
    mkdir -p $out/include
    install -m 755 ./libmathpresso.so $out/lib
    install -m 644 $src/src/mathpresso/mathpresso.h $out/include
    '';

  meta = with lib; {
    description = "Mathematical expression parser and JIT compiler";
    license = licenses.zlib;
    platforms = platforms.unix;
    #maintainers = with maintainers; [ xxx ];
  };
}
