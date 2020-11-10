{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, pkgconfig, pmix, ucx, numactl, libbfd, libiberty, perl } :

let
  version = "1.0";

in stdenv.mkDerivation {
  name = "osss-ucx-${version}";

  src = fetchFromGitHub {
    owner = "openshmem-org";
    repo = "osss-ucx";
    rev = "v${version}";
    sha256 = "0difh5j6b82mpbzdylmzf948w1pxvnrc9x047hgr720d283c7326";
  };

  nativeBuildInputs = [ autoconf automake libtool pkgconfig ];
  buildInputs = [ pmix ucx numactl libbfd libiberty perl ];

  configureFlags = [
    "--with-pmix=${pmix}"
    "--with-ucx=${ucx}"
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  postFixup = ''
    # Ensure tp use the same compiler as the build
    sed -i 's:gcc:${stdenv.cc}/bin/gcc:' $out/bin/oshcc
    sed -i 's:g++:${stdenv.cc}/bin/g++:' $out/bin/oshc++
  '';

  meta = with stdenv.lib; {
    description = "";
    homepage = https://;
    license = licenses.bsd3;
    maintainers = [  ];
    platforms = platforms.linux;
  };
}

