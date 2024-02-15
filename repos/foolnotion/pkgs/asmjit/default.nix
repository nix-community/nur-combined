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
    rev    = "d82e478fb8d3a5a36fbd8090e7abafebbcbc2447";
    sha256 = "sha256-nv92gAZdTsndQtoBq+goDNHTOVMu3tGCFANPTzAIK0E=";
  };

  meta = with lib; {
    description = "AsmJit is a lightweight library for machine code generation written in C++ language.";
    license = licenses.zlib;
    platforms = platforms.unix;
    #maintainers = with maintainers; [ xxx ];
  };
}
