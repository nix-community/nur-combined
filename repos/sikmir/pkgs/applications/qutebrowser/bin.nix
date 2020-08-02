{ stdenv, fetchfromgh, undmg }:
let
  pname = "qutebrowser";
  version = "1.13.1";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchfromgh {
    owner = "qutebrowser";
    repo = "qutebrowser";
    version = "v${version}";
    name = "qutebrowser-${version}.dmg";
    sha256 = "0ddm15ps896q70av3ndyd75vdqz7hvgpn07nbrniwrmfsd4nmm8f";
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
