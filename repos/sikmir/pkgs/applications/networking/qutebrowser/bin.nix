{ lib, stdenv, fetchfromgh, undmg }:

stdenv.mkDerivation rec {
  pname = "qutebrowser-bin";
  version = "1.14.1";

  src = fetchfromgh {
    owner = "qutebrowser";
    repo = "qutebrowser";
    version = "v${version}";
    name = "qutebrowser-${version}.dmg";
    sha256 = "1a4pakpn39pq72bgkqd1f1rik139c0shjfszxh1iqn7fb3dqrqmj";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  meta = with lib; {
    description = "A keyboard-driven, vim-like browser based on PyQt5";
    homepage = "https://www.qutebrowser.org/";
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-darwin" ];
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };
}
