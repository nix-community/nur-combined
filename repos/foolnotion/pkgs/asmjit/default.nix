{ stdenv
, lib
, fetchFromGitHub
, cmake }: 

stdenv.mkDerivation {
  pname = "asmjit";
  version = "git";

  nativeBuildInputs = [ cmake ];

  src = fetchFromGitHub {
    repo   = "asmjit";
    owner  = "asmjit";
    rev    = "70e80b18a5cc05d566e6c90dde200472c9325113";
    sha256 = "0if6npdx1qxvxdlkvnil8lqx3vclx2i2bliyj5xrl1ha0vnffmws";
  };

  meta = with lib; {
    description = "AsmJit is a lightweight library for machine code generation written in C++ language.";
    license = licenses.zlib;
    platforms = platforms.unix;
    #maintainers = with maintainers; [ xxx ];
  };
}
