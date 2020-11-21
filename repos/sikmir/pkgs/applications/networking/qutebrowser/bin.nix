{ stdenv, fetchfromgh, undmg }:

stdenv.mkDerivation rec {
  pname = "qutebrowser";
  version = "1.14.0";

  src = fetchfromgh {
    owner = "qutebrowser";
    repo = "qutebrowser";
    version = "v${version}";
    name = "qutebrowser-${version}.dmg";
    sha256 = "03d5bf5lpxyphi0ri6ykh7dr6izsikk22ivh6mh09q0a2y0kdf44";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = "qutebrowser.app";

  installPhase = ''
    mkdir -p $out/Applications/qutebrowser.app
    cp -R . $out/Applications/qutebrowser.app
  '';

  meta = with stdenv.lib; {
    description = "A keyboard-driven, vim-like browser based on PyQt5";
    homepage = "https://www.qutebrowser.org/";
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-darwin" ];
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };
}
