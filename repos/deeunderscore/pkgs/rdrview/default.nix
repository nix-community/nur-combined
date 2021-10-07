{ stdenv
, lib
, fetchFromGitHub
, libxml2
, libseccomp
, curl
}:
stdenv.mkDerivation {
  pname = "rdrview";
  version = "unstable-2021-09-13";

  src = fetchFromGitHub {
    owner = "eafer";
    repo = "rdrview";
    rev = "9bde19f9e53562790b363bb2e3b15707c8c67676";
    sha256 = "sha256-46JY6WuLYHLJl3omgmysR/TGO3zrrJO397x7/EJVz/A=";
  };

  buildInputs = [ libxml2 libseccomp curl ];
  installPhase = ''
    make install BINDIR="$out/bin" MANDIR="$out/share/man/man1"
  '';

  meta = {
    description = "Firefox Reader View as a Linux command line tool ";
    homepage = "https://github.com/eafer/rdrview";
    license = lib.licenses.asl20;
  };
}
