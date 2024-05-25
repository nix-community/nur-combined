{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kilo";
  version = "0-unstable-2020-07-05";

  src = fetchFromGitHub {
    owner = "antirez";
    repo = "kilo";
    rev = "69c3ce609d1e8df3956cba6db3d296a7cf3af3de";
    hash = "sha256-6zPzaUzBQCIciuzBp4W6pT4bvhWbC8t6bSVec5LBRiU=";
  };

  installPhase = ''
    install -Dm755 kilo -t $out/bin
  '';

  meta = {
    description = "A text editor in less than 1000 LOC with syntax highlight and search";
    inherit (finalAttrs.src.meta) homepage;
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
