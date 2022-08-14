{ lib, fetchFromGitHub, tcl, tk, libX11, zlib, makeWrapper, cmake }:

tcl.mkTclDerivation rec {
  pname = "scid";
  version = "4.8.0";

  src = fetchFromGitHub {
    owner = "benini";
    repo = "scid";
    rev = "5a1e3dbfd36529a52cb90004ac4fa4a1b6bbb60e";
    sha256 = "sha256-iXNqDLgMBg0Gtupvji+YoXTIBYvdpACVJf19y+dlWNA=";
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
