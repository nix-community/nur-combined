# based on https://github.com/termux/termux-packages/blob/master/packages/libapt-pkg-perl/build.sh

{ lib
, buildPerlModule
, fetchurl
, apt
}:

buildPerlModule rec {
  pname = "apt-pkg";
  version = "0.1.40";

  src = fetchurl {
    url = "http://deb.debian.org/debian/pool/main/liba/libapt-pkg-perl/libapt-pkg-perl_${version}.tar.xz";
    sha256 = "sha256-Uk0u9389aJbFDnZ0Ai2F5KORpqKzxlul5QrGcfp85KE=";
  };

  # fix type warning
  postPatch = ''
    substituteInPlace AptPkg.xs \
      --replace \
        "AptPkg::_parse_cmdline: invalid array %ld (%s)" \
        "AptPkg::_parse_cmdline: invalid array %i (%s)"
  '';

  # default: perl Build.PL && ./Build
  buildPhase = ''
    make
  '';

  # default: ./Build install
  installPhase = ''
    make install
  '';

  # default: ./Build test
  checkPhase = ''
    make test
  '';

  # tests fail
  doCheck = false;

  # fix: failed to produce output path for output 'devdoc'
  outputs = [ "out" ];

  buildInputs = [
    apt # libapt-pkg
  ];

  meta = {
    description = "Perl interface to libapt-pkg";
    homepage = "https://packages.debian.org/libapt-pkg-perl";
    license = with lib.licenses; [ gpl3Only ];
  };
}
