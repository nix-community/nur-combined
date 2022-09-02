{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "json2tsv";
  version = "1.0";

  src = fetchgit {
    url = "git://git.codemadness.org/json2tsv";
    rev = version;
    hash = "sha256-xYF+qYyjz0kzOnez1pMwJKnlx0UCYlXZJEpjwdSqhhk=";
  };

  postPatch = ''
    substituteInPlace jaq --replace "json2tsv" "$out/bin/json2tsv"
  '';

  makeFlags = [ "RANLIB:=$(RANLIB)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "JSON to TSV converter";
    homepage = "https://git.codemadness.org/json2tsv/file/README.html";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
