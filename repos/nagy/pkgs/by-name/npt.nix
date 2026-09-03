{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "npt";
  version = "1.1.1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nptcl";
    repo = "npt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jDOdz5k2xWj8fkidNErNBT9oACnTwJWK5XasnMtGmQk=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  enableParallelBuilding = true;

  meta = {
    description = "ANSI Common Lisp implementation";
    homepage = "https://github.com/nptcl/npt";
    license = lib.licenses.unlicense;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ nagy ];
  };
})
