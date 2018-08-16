{ stdenv, fetchFromGitHub, fetchurl, fcd, curl, gnutar }:

let
  deburl = "http://ftp.us.debian.org/debian/pool/main";
  glibcpath = "g/glibc/libc6-dev_2.24-9_amd64.deb";
  libcpath = "l/linux/linux-libc-dev_3.16.39-1_amd64.deb";
  glibcdeb = fetchurl {
    url = "${deburl}/${glibcpath}";
    sha256 = "08lhydw72rm0gdzh62nfnx5lbsxm7mv78ncdx8av9cr737kkd9kz";
  };
  libcdeb = fetchurl {
    url = "${deburl}/${libcpath}";
    sha256 = "1wxmlrqa8hs554y4gs9nzk3f7j8ah90i4snjv25x3la7jkzcsqj5";
  };
  apple_libcpath = "Libc/Libc-1158.30.7.tar.gz";
  apple_url = "https://opensource.apple.com/tarballs";
  apple_libc = fetchurl {
    url = "${apple_url}/${apple_libcpath}";
    sha256 = "0qggx4nn2iq8fqfy9jvphsgf6y9zdbxskaqjanm3aww1c6zxj2c0";
  };
in stdenv.mkDerivation rec {
  name = "fcd-tests-${version}";
  version = "2017-04-02";
  src = fetchFromGitHub {
    owner = "zneak";
    repo = "fcd-tests";
    rev = "74cfc614b7bb9012026568990aa204ad372cfa54";
    sha256 = "0lhfzqhhbgpclvcarhmnz8blrf4h6qf8inf931agxj5hywn3rxyl";
  };

  buildInputs = [ fcd curl gnutar ];

  patchPhase = ''
    patchShebangs do-test.sh

    install -D ${glibcdeb} $PWD/local/${glibcpath}
    install -D ${libcdeb} $PWD/local/${libcpath}
    mkdir -p download $PWD/include/apple/Libc
    touch download/${builtins.baseNameOf apple_libcpath}
    tar xf ${apple_libc} -C $PWD/include/apple/Libc
    substituteInPlace do-test.sh \
      --replace "${deburl}" "file://$PWD/local" \
      --replace '"''${BASEDIR}/../scripts/' '"${fcd}/share/fcd/scripts/'

  '';

  buildPhase = ''
    ./do-test.sh ${fcd}/bin/fcd
  '';

  installPhase = ''
    mkdir -p $out/
    mv SUMMARY.md error output $out/
  '';

  meta = with stdenv.lib; {
    description = "Tests for fcd";
    homepage = https://zneak.github.io/fcd;
    license = licenses.ncsa;
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}

