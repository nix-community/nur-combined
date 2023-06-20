{
  lib,
  stdenv,
  fetchzip,
  pkg-config,
  libtermkey,
  unibilium,
  libtool,
}:
stdenv.mkDerivation rec {
  pname = "libtickit";
  version = "0.4.3";

  src = fetchzip {
    url = "https://www.leonerd.org.uk/code/libtickit/libtickit-${version}.tar.gz";
    sha256 = "sha256-dKjmHojZBPP0ZQGXsno+2nFf1GCNmljWF2FklCMGCos=";
  };

  makeFlags = ["PREFIX=$(out)"];

  nativeBuildInputs = [pkg-config libtermkey unibilium libtool];

  meta = with lib; {
    description = "A terminal interface construction kit";
    longDescription = ''
      This library provides an abstracted mechanism for building interactive full-screen terminal
      programs. It provides a full set of output drawing functions, and handles keyboard and mouse
      input events.
    '';
    homepage = "https://www.leonerd.org.uk/code/libtickit/";
    license = licenses.mit;
  };
}
