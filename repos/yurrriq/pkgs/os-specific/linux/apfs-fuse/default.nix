{ stdenv, fetchFromGitHub, fuse, zlib, bzip2, cmake, git }:

stdenv.mkDerivation rec {
  pname = "apfs-fuse";
  version = "2019-04-20";

  src = fetchFromGitHub {
    owner = "sgan81";
    repo = pname;
    rev = "ee7dfe0e8c6efb092b36885c841dd30d30f952f0";
    fetchSubmodules = true;
    sha256 = "00sg7dirimwwwvzv6ajgncvy2wxy4hvi56h38nzcr1hv343dljh8";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ fuse zlib bzip2 ];

  installPhase = ''
    install -dm755 "$out/bin"
    install -m755 -t "$_" apfs-dump apfs-dump-quick apfs-fuse apfsutil
  '';

  meta = with stdenv.lib; {
    description = "FUSE driver for APFS";
    inherit (src.meta) homepage;
    maintainer = with maintainers; [ yurrriq ];
    platforms = platforms.linux;
    license = licenses.gpl2;
  };
}
