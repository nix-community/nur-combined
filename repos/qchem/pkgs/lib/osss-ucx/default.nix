{ lib, stdenv, fetchFromGitHub, autoconf, automake, libtool
, pkgconfig, pmix, ucx, numactl, libbfd, libiberty, perl } :

let
  version = "1.0.2";

in stdenv.mkDerivation {
  name = "osss-ucx-${version}";

  src = fetchFromGitHub {
    owner = "openshmem-org";
    repo = "osss-ucx";
    rev = "v${version}";
    sha256 = "0nialkl70l9f68znbsi76gvy52s6g098zm328xla0i7j035h3y7a";
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

  meta = with lib; {
    description = "";
    homepage = "http://www.openshmem.org";
    license = licenses.bsd3;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}

