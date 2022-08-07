{ lib, fetchFromGitHub, tcl, tk, libX11, zlib, makeWrapper, cmake }:

tcl.mkTclDerivation rec {
  pname = "scid";
  version = "4.8.0";

  src = fetchFromGitHub {
    owner = "benini";
    repo = "scid";
    rev = "v${version}";
    sha256 = "sha256-7uRshBTNjNea9PRPgnkF+fDHec0V6DDJ8h1llguXqq0=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ tk libX11 zlib ];

  prePatch = ''
    sed -i -e '/^ *set headerPath *{/a ${tcl}/include ${tk}/include' \
           -e '/^ *set libraryPath *{/a ${tcl}/lib ${tk}/lib' \
           -e '/^ *set x11Path *{/a ${libX11}/lib/' \
           configure
  '';

  configureFlags = [
    "BINDIR=$(out)/bin"
    "SHAREDIR=$(out)/share"
  ];

  hardeningDisable = [ "format" ];

  dontPatchShebangs = true;

  # TODO: can this use tclWrapperArgs?
  postFixup = ''
    for cmd in $out/bin/*
    do
      wrapProgram "$cmd" \
        --set TK_LIBRARY "${tk}/lib/${tk.libPrefix}"
    done
  '';

  meta = {
    description = "Chess database with play and training functionality";
    maintainers = with lib.maintainers; [ agbrooks ];
    homepage = "http://scid.sourceforge.net/";
    license = lib.licenses.gpl2;
  };
}
