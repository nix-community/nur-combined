{ stdenv
, fetchurl
, fetchFromGitHub
, python3
, bison
, perl
, makeWrapper
}:

let
  mbedtlsVersion = "2.21.0";
  mbedtls = fetchurl {
    url = "https://github.com/ARMmbed/mbedtls/archive/mbedtls-${mbedtlsVersion}.tar.gz";
    sha256 = "1f9dc0hpmp4g3l90wlk3glx5xl0hnnabmjagmr8fdbcnfl5r63ij";
  };
  mbedcryptoVersion = "3.1.0";
  mbedcrypto = fetchurl {
    url = "https://github.com/ARMmbed/mbed-crypto/archive/mbedcrypto-${mbedcryptoVersion}.tar.gz";
    sha256 = "0sxpz3anpwv1cff606jjzxq4pbkh3s1k16a82b3in0v06pq1s5vy";
  };

  glibcVersion = "2.31";
  glibc = fetchurl {
    url = "https://mirrors.ocf.berkeley.edu/gnu/glibc/glibc-${glibcVersion}.tar.gz";
    sha256 = "19xxlbz6q3ahyjdfjjmcrg17v9iakpg8b6m9v0qgzzwah3xn8bfb";
  };
in stdenv.mkDerivation {
  name = "graphene";

  src = fetchFromGitHub {
    owner = "oscarlab";
    repo = "graphene";
    rev = "d97183865d6af4bf75fd7ef108d1b3baabb6f578";
    sha256 = "1z768855929chz5pl1xcvvwp84p0pcxlwql3n29w5ncbv3jh2rqv";
  };

  patches = [
    ./shebang-bypass.patch
    ./pal-loader.patch
  ];

  DL_OFFLINE = "true";

  postPatch = ''
    patchShebangs ./Scripts
    ln -s ${mbedtls} Pal/lib/crypto/mbedtls-${mbedtlsVersion}.tar.gz
    ln -s ${mbedcrypto} Pal/lib/crypto/mbedcrypto-${mbedcryptoVersion}.tar.gz
    ln -s ${glibc} LibOS/glibc-${glibcVersion}.tar.gz
  '';

  installPhase = ''
    mkdir -p $out/share/graphene

    for lib in Runtime/*.so* Runtime/pal-* Runtime/pal_loader; do
      # copy symlinks and dereferenced lib
      cp $lib $out/share/graphene
      cp $(realpath "$lib") $out/share/graphene
    done
    makeWrapper $out/share/graphene/pal_loader $out/bin/pal_loader \
      --set PAL_HOST Linux
  '';

  nativeBuildInputs = [
    python3
    bison
    perl
    makeWrapper
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Graphene Library OS with Intel SGX Support";
    homepage = "https://github.com/oscarlab/graphene";
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
