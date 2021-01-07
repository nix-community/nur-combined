{ stdenv, lib, makeWrapper, fetchFromGitHub, gnused, jq, sxiv }:

stdenv.mkDerivation rec {
  pname = "rofi-menu";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = pname;
    rev = version; 
    sha256 = "0dggyh6c3w2bnjy2c6w1hwrwcms47ncp2i1z20hmm9hqrdxg0d66";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -D rofi-menu-history $out/bin/rofi-menu-history
  '';

  postFixup = ''
    wrapProgram $out/bin/rofi-menu-history --prefix PATH : ${lib.makeBinPath [ gnused jq sxiv ]}
  '';

  meta = with stdenv.lib; {
    description = "Various rofi menus (aka. modi)";
    homepage = "https://github.com/emmanuelrosa/rofi-menu";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
