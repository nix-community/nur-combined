{ lib, fetchFromGitHub, tcl, tk, libX11, zlib, makeWrapper, cmake }:

tcl.mkTclDerivation rec {
  pname = "scid";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "benini";
    repo = "scid";
    rev = "5aade37aabff6966fc7f1508f82fe8f5fb3fbd64";
    sha256 = "sha256-o1IQp2WZXFf5rzisSyz85Qrwbe7O+HnLkBXUQalIpRs=";
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
