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
    sha256 = "sha256-k8knJWvo9s2H9dh0Wh+CEFE/UrGc+iaXNvZ2JsQ4Zf8=";
  };

  env = {
    CFLAGS = "-std=gnu99";
  };

  buildPhase = ''
    sh build.sh --nolua53 --luahb --parallel
  '';

  installPhase = ''
    install -D build/texk/web2c/luahbtex $out/bin/texlua
    install -Dm644 source/texk/kpathsea/texmf.cnf -t $out/etc/texmf/web2c
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/manpager";
    description = "Colorize `man XXX`";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
