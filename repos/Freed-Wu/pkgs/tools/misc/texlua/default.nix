{
  lib,
  stdenv,
  fetchzip,
}:
stdenv.mkDerivation rec {
  pname = "texlua";
  version = "1.17.0";
  src = fetchzip {
    url = "https://gitlab.lisn.upsaclay.fr/texlive/luatex/-/archive/${version}/luatex-${version}.zip";
    sha256 = "sha256-xPrm8BMM9yZwblf7IIO6PesvThKX/9d06wXjy0VoWPo=";
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
    install -D build/texk/web2c/luahbtex $out/bin/texlua
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
