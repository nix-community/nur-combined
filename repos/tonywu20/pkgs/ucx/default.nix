{ lib, stdenv, fetchFromGitHub, fetchpatch, autoreconfHook, doxygen
, numactl, rdma-core, libbfd, libiberty, perl, zlib, symlinkJoin
, pkg-config
, enableCuda ? false
, enableRocm ? false
, cudatoolkit
, rocmPackages
}:

let
  # Needed for configure to find all libraries
  cudatoolkit' = symlinkJoin {
    inherit (cudatoolkit) name meta;
    paths = [ cudatoolkit cudatoolkit.lib ];
  };
  rocm = symlinkJoin {
    name = "rocm";
    paths = [ rocmPackages.rocm-core rocmPackages.rocm-runtime rocmPackages.rocm-device-libs rocmPackages.clr ];
  };

in stdenv.mkDerivation rec {
  pname = "ucx";
  version = "1.16.0-rc3";

  src = fetchFromGitHub {
    owner = "openucx";
    repo = "ucx";
    rev = "v${version}";
    sha256 = "sha256:0i44yd3hszyi1ah5frp8kffbsr1pacjpfidphzlab6xm1jbhn2y4";
  };

  nativeBuildInputs = [ autoreconfHook doxygen pkg-config ];

  buildInputs = [
    libbfd
    libiberty
    numactl
    perl
    rdma-core
    zlib
  ] ++ lib.optional enableCuda cudatoolkit
    ++ lib.optional enableRocm [ rocmPackages.rocm-core rocmPackages.rocm-runtime rocmPackages.rocm-device-libs rocmPackages.clr ];

  configureFlags = [
    "--with-rdmacm=${lib.getDev rdma-core}"
    "--with-dc"
    "--with-rc"
    "--with-dm"
    "--with-verbs=${rdma-core}"
  ] ++ lib.optional enableCuda "--with-cuda=${cudatoolkit'}"
    ++ lib.optional enableRocm "--with-rocm=${rocm}";

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Unified Communication X library";
    homepage = "https://www.openucx.org";
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = [ maintainers.markuskowa ];
  };
}
