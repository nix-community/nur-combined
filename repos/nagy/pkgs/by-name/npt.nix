{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "npt";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "nptcl";
    repo = "npt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jDOdz5k2xWj8fkidNErNBT9oACnTwJWK5XasnMtGmQk=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "ANSI Common Lisp implementation";
    homepage = "https://github.com/nptcl/npt";
    license = licenses.unlicense;
    platforms = platforms.all;
  };
})
