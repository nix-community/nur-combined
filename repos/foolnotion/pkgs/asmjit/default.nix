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
    rev    = "06d0badec53710a4f572cf5642881ce570c5d274";
    sha256 = "sha256-fMSttVxIQSQpgAxJl4V9CeN6HWXXIBlqp+KiIOVpByY=";
  };

  meta = with lib; {
    description = "AsmJit is a lightweight library for machine code generation written in C++ language.";
    license = licenses.zlib;
    platforms = platforms.unix;
    #maintainers = with maintainers; [ xxx ];
  };
}
