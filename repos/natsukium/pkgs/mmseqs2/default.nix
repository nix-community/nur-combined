{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  xxd,
  perl,
  enableAvx2 ? stdenv.hostPlatform.avx2Support,
  enableSse4_1 ? stdenv.hostPlatform.sse4_1Support,
  enableMpi ? (false && !stdenv.isDarwin),
  mpi,
  openmp,
  zlib,
  bzip2,
}:
with lib;
  stdenv.mkDerivation rec {
    pname = "mmseqs2";
    version = "14-7e284";

    src = fetchFromGitHub {
      owner = "soedinglab";
      repo = pname;
      rev = version;
      sha256 = "sha256-pVryZGblgMEqJl5M20CHxav269yGY6Y4ci+Gxt6SHOU=";
    };

    nativeBuildInputs = [cmake xxd perl];
    cmakeFlags =
      optional enableAvx2 "-DHAVE_AVX2=1"
      ++ optional enableSse4_1 "-DHAVE_SSE4_1=1"
      ++ optional enableMpi "-DHAVE_MPI=1";

    buildInputs = optionals stdenv.cc.isClang [openmp zlib bzip2] ++ optional enableMpi mpi;

    meta = {
      description = "Ultra fast and sensitive sequence search and clustering suite";
      homepage = "https://mmseqs.com/";
      license = licenses.gpl3;
      platforms = platforms.unix;
    };
  }
