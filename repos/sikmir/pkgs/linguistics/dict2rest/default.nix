{
  lib,
  fetchFromGitHub,
  buildGoPackage,
}:

buildGoPackage rec {
  pname = "dict2rest";
  version = "0-unstable-2016-12-05";

  src = fetchFromGitHub {
    owner = "felix";
    repo = "go-dict2rest";
    rev = "b049991a46a2f619344bd6e915745703864d0134";
    hash = "sha256-v5vBsdGQZYHSPEiBgSezKqaev1sTXnP27Tn47z1ebjQ=";
  };

  goPackagePath = "github.com/felix/go-dict2rest";

  meta = with lib; {
    description = "A simple proxy service providing an HTTP interface to a Dict protocol (RFC 2229) server";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    mainProgram = "go-dict2rest";
  };
}
