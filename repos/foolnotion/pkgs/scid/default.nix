{ lib, fetchFromGitHub, tcl, tk, libX11, zlib, makeWrapper, cmake }:

tcl.mkTclDerivation rec {
  pname = "scid";
  version = "5.0.2";

  src = fetchFromGitHub {
    owner = "benini";
    repo = "scid";
    rev = "v${version}";
    sha256 = "sha256-5WGZm7EwhZAMKJKxj/OOIFOJIgPBcc6/Bh4xVAlia4Y=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ tk libX11 zlib ];

  # TODO: can this use tclWrapperArgs?
  postFixup = ''
    for cmd in $out/bin/*
    do
      wrapProgram "$cmd" \
        --set TK_LIBRARY "${tk}/lib/${tk.libPrefix}"
    done
    wrapProgram $out/scid/scid \
        --set TK_LIBRARY "${tk}/lib/${tk.libPrefix}" \
        --set TCLLIBPATH "${tk}/lib/${tk.libPrefix}"
    ln -s $out/scid/scid $out/bin/
  '';

  meta = {
    description = "Chess database with play and training functionality";
    maintainers = with lib.maintainers; [ agbrooks ];
    homepage = "https://github.com/benini/scid";
    license = lib.licenses.gpl2Only;
  };
}
