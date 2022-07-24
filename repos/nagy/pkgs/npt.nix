{ stdenv, lib, fetchFromGitHub, autoreconfHook }:

stdenv.mkDerivation rec {
  pname = "npt";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "nptcl";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-jDOdz5k2xWj8fkidNErNBT9oACnTwJWK5XasnMtGmQk=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  meta = with lib; {
    description = "ANSI Common Lisp implementation";
    homepage = "https://github.com/nptcl/npt";
    license = licenses.unlicense;
    platforms = platforms.all;
  };
}
