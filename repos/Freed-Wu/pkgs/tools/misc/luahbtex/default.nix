{
  lib,
  stdenv,
  fetchzip,
}:
stdenv.mkDerivation rec {
  pname = "luahbtex";
  version = "1.23.3";
  src = fetchzip {
    url = "https://gitlab.lisn.upsaclay.fr/texlive/luatex/-/archive/${version}/luatex-${version}.zip";
    sha256 = "sha256-FmC00uXFqb/YZHkoyO1Z2z6u/tvEn2Xorg33e9q5zUI=";
  };

  env = {
    CFLAGS = "-std=gnu99";
  };

  patches = [
    ./fix-LUA_ROOT.patch
  ];

  buildPhase = ''
    sh build.sh --nolua53 --luahb --parallel
  '';

  installPhase = ''
    install -D build/texk/web2c/luahbtex -t $out/bin
    install -Dm644 source/texk/kpathsea/texmf.cnf -t $out/etc/texmf/web2c
  '';

  meta = with lib; {
    homepage = "https://www.luatex.org/";
    description = "The LuaTeX project's main objective is to provide an open and configurable variant of TeX while at the same time offering downward compatibility";
    license = licenses.gpl2;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
