{ lib, stdenv, fetchwebarchive, fetchpatch, readline, ncurses, bison, flex, installShellFiles }:

stdenv.mkDerivation rec {
  pname = "aamath";
  version = "0.3";

  src = fetchwebarchive {
    url = "http://fuse.superglue.se/aamath/aamath-${version}.tar.gz";
    timestamp = "20190303013301";
    hash = "sha256-mEP0WIaV4s1Vzl2PWJIdTyVeDmXtlWnh3N3z9o93tjE=";
  };

  patches = (fetchpatch {
    url = "https://raw.githubusercontent.com/macports/macports-ports/6c3088afddcf34ca2bcc5c209f85f264dcf0bc69/math/aamath/files/patch-expr.h.diff";
    hash = "sha256-JtLcqdBq/88Bemj4NQYnpEVVTUyiCLWX2zE3CuXtRlM=";
  });

  patchFlags = [ "-p0" ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace "lex " "flex " \
      --replace "-ltermcap" "-lncurses"
  '';

  nativeBuildInputs = [ bison flex installShellFiles ];

  buildInputs = [ readline ncurses ];

  installPhase = ''
    install -Dm755 aamath -t $out/bin
    installManPage aamath.1
  '';

  meta = with lib; {
    description = "ASCII art mathematics";
    homepage = "http://fuse.superglue.se/aamath/";
    license = licenses.gpl2Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
