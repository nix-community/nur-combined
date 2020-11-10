{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, doxygen, numactl, rdma-core, libbfd, libiberty, perl
, zlib
# Enable machine-specific optimizations
, enableOpt ? false
} :

let
  version = "1.7.0";

in stdenv.mkDerivation {
  name = "ucx-${version}";

  src = fetchFromGitHub {
    owner = "openucx";
    repo = "ucx";
    rev = "v${version}";
    sha256 = "149p8s7jrg7pbbq0hw0qm8va119bsl19q4scgk94vjqliyc1s33h";
  };

  nativeBuildInputs = [ autoconf automake libtool doxygen ];

  buildInputs = [ numactl rdma-core libbfd libiberty perl zlib ];

  configureFlags = [
    "--with-rdmacm=${rdma-core}"
    "--with-dc"
    "--with-rc"
    "--with-dm"
    "--with-verbs=${rdma-core}"
  ] ++ stdenv.lib.optionals enableOpt  [
      "--with-avx"
      "--with-sse41"
      "--with-sse42"
    ];

  enableParallelBuilding = true;

  preConfigure = ''
    ./autogen.sh
  '';

  meta = with stdenv.lib; {
    description = "Unified Communication X library";
    homepage = http://www.openucx.org;
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = [ maintainers.markuskowa ];
  };
}

