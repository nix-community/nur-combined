# TODO extract rfcs into own derivation so the outputs are cached
{ stdenv, fetchFromGitHub, fetchurl, python3, pythonPackages }:
let
  src = fetchFromGitHub {
    owner = "monsieurh";
    repo = "rfc_reader";
    rev = "0z63rn6zvhp4hh4pvyqil0zrczv0ynhr0652m0q5raxgha2karw8";
    sha256 = "0w47inhd57h62fylvxlklxp0s52yjmpzky47pg277bwzly42vbcv";
  };

  rfcs = fetchurl {
    url = "https://www.rfc-editor.org/in-notes/tar/RFC-all.tar.gz";
    #sha256 = "1awln69q48qykvaxssvf8ndbgsxcjdj4r0rbas3yqxhqbx9nyg0j";  #--unpack
    sha256 = "147v8dfygnn25mhjaszv9i2v30pbhjmych55zkaaq42vgmbjr8vr";
  };

  rfc-index = fetchurl {
    url = "https://www.ietf.org/download/rfc-index.txt";
    sha256 = "0z63rn6zvhp4hh4pvyqil0zrczv0ynhr0652m0q5raxgha2karw8";
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

  meta = with stdenv.lib; {
    description = "The CLI RFC reader";
    license = licenses.gpl3;
    homepage = https://github.com/monsieurh/rfc_reader;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}

