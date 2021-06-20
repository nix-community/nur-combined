{ stdenv, lib, fetchFromGitHub, pkgconfig, libtool, curl
, python, munge, perl, pam, openssl, zlib
, ncurses, libmysqlclient, lua, hwloc, numactl
, readline, freeipmi, libssh2, lz4, autoconf, automake, gtk2, version ? "17"
}:

let
  versionMap = {
  "14" = {
    bsc_simulatorVersion = "bsc-v14";
    rev = "91d0b7145a15b071eff26b8d4b95a23c008a4550"; 
    sha256 = "0rhq4cbmppd79bvasyvd59ki0s6r5d8iqm2xpmgc045qvgjlmabk";
  };
  "17" = {
    bsc_simulatorVersion = "bsc-v17";
    rev="0fc334bdbc5942d1a27f42f635afcb8d58e46e9b";
    sha256 = "0ib07c4x781z8ih4bj6j5pqjyz43x94q5mkp5favvpzqbb1z00dr";
  };
};
in

with versionMap.${version};

stdenv.mkDerivation rec {
  name = "slurm-simulator-${bsc_simulatorVersion}";

  src = fetchFromGitHub {
    owner = "augu5te";
    repo = "slurm_simulator";
    inherit rev;
    inherit sha256;
  };
  
  outputs = [ "out" "dev" ];

  # nixos test fails to start slurmd with 'undefined symbol: slurm_job_preempt_mode'
  # https://groups.google.com/forum/#!topic/slurm-devel/QHOajQ84_Es
  # this doesn't fix tests completely at least makes slurmd to launch
  hardeningDisable = [ "bindnow" ];

  nativeBuildInputs = [ pkgconfig libtool ];
  buildInputs = [
    curl python munge perl pam openssl zlib
    libmysqlclient ncurses lz4 
    lua hwloc numactl readline
    autoconf automake gtk2
  ];
 
  preBuild = ''
    makeFlagsArray+=("CFLAGS=-DSLURM_SIMULATOR -g0 -O2 -D NDEBUG=1 -DNUMA_VERSION1_COMPATIBILITY -pthread -lrt")
  '';

  #makeFlags = ''CFLAGS="-D SLURM_SIMULATOR -g0 -O3 -D NDEBUG=1"'';
  #makeFlags = "CFLAGS=-DSLURM_SIMULATOR";
  configureFlags = with lib;
    [ #"--with-hwloc=${hwloc.dev}"
      "--with-lz4=${lz4.dev}"
      "--with-ssl=${openssl.dev}"
      "--with-zlib=${zlib}"
      "--sysconfdir=/etc/slurm"
      "--enable-front-end"
      "--disable-debug"
      "--enable-simulator" 
    ];

  preConfigure = ''
    patchShebangs ./doc/html/shtml2html.py
    patchShebangs ./doc/man/man2html.py
    ./autogen.sh
  '';

  preInstall = ''
    cd contribs/simulator
    make CFLAGS="-DSLURM_SIMULATOR -g0 -O2 -D NDEBUG=1 -DNUMA_VERSION1_COMPATIBILITY -pthread -lrt"
    cd -
  '';
  
  postInstall = ''
    rm -f $out/lib/*.la $out/lib/slurm/*.la
    cd contribs/simulator
    make install
    cd -
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    broken = true;
    homepage = http://www.schedmd.com/;
    description = "Simple Linux Utility for Resource Management";
    platforms = platforms.linux;
    license = licenses.gpl2;
    maintainers = with maintainers; [ jagajaga markuskowa ];
  };
}
