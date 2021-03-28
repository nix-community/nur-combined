# TODO extract rfcs into own derivation so the outputs are cached
{ stdenv, lib, fetchFromGitHub, fetchurl, python3, pythonPackages }:
let
  src = fetchFromGitHub {
    owner = "monsieurh";
    repo = "rfc_reader";
    rev = "5679eb901e3ba49ce4a89583914b025e8088a210";
    sha256 = "0w47inhd57h62fylvxlklxp0s52yjmpzky47pg277bwzly42vbcv";
  };

  rfcs = fetchurl {
    # We can't use the upstream URL because they update it every day
    # url = "https://www.rfc-editor.org/in-notes/tar/RFC-all.tar.gz";
    url = "https://danielschaefer.me/rfc/2018-09-10/RFC-all.tar.gz";
    sha256 = "1100h1n9ksmhfb8fnsj9hy7cfhj37m4985bcl3zzx8w0rp16vvq2";
  };

  rfc-index = fetchurl {
    # We can't use the upstream URL because they update it every day
    # url = "https://www.ietf.org/download/rfc-index.txt";
    url = "https://danielschaefer.me/rfc/2018-09-10/rfc-index.txt";
    sha256 = "0dsdsjjywvqa8aflm6snf3229q3p3bj3ka0n5pqvashbqz3s9h68";
  };
in
pythonPackages.buildPythonApplication rec {
  name = "rfc-reader-${version}";
  version = "2016-07-14";

  inherit src;

  patches = [ ./cache-dir.diff ];

  postInstall = ''
    mkdir -p $out/cache
    tar xf ${rfcs} -C $out/cache
    cp ${rfc-index} $out/cache
  '';

  makeWrapperArgs = [
    ''
      --set RFC_READER_CACHE "$out/cache"
    ''
  ];

  meta = with lib; {
    description = "The CLI RFC reader";
    license = licenses.gpl3;
    homepage = https://github.com/monsieurh/rfc_reader;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}

