{ stdenv, fetchurl, perl, rdma-core, libfabric
, fetchFromGitHub, libelf, gfortran
, conduit ? "smp" # communication model: smp, udp, ibv, ofi
} :

let
  version = "1.3";

  gasnet = stdenv.mkDerivation rec {
    version = "1.32.0";
    name = "gasnet-${version}";

    src = fetchurl {
      url = "https://gasnet.lbl.gov/download/GASNet-${version}.tar.gz";
      sha256 = "048mxqqpwk22gzs32v7lff85fksrdgl6q6y4fwpi8z5w7d5pgr22";
    };

    buildInputs = [ perl rdma-core libfabric ];

    doCheck = true;
  };

in stdenv.mkDerivation {
  name = "openshmem-${conduit}-${version}";

  src = fetchFromGitHub {
    repo = "openshmem";
    owner = "openshmem-org";
    rev = "release-${version}";
    sha256 = "17nac6121dkh11j71q6idk4dqfw5kh5w80qazm3yg4s75i16d05g";
  };

  buildInputs = [ libelf gasnet gfortran ];

  configureFlags = [
    "--with-libelf=${libelf}"
    "--with-compiler=GNU"
    "--enable-pshmem"
    "--with-comms-layer=gasnet"
    "--with-gasnet-root=${gasnet}"
    "--with-gasnet-conduit=${conduit}"
  ];

  preConfigure = ''
    patchShebangs configure
  '';

  postInstall = ''
    mkdir -p $out/share/doc/openshmem
    mv $out/modulefiles/ $out/share/doc/openshmem
  '';

  meta = with stdenv.lib; {
    description = "Partitioned global address space (PGAS) library";
    homepage = http://www.openshmem.org;
    longDescription = "Reference implementation for the OpenSHMEM API";
    maintainers = with maintainers; [ markuskowa ];
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}

