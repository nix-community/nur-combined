{ stdenv, lib, makeWrapper, fetchFromGitHub, gnused, jq, sxiv }:

stdenv.mkDerivation rec {
  pname = "rofi-menu";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = pname;
    rev = version; 
    sha256 = "1vnd5fm8s68xcdqlykmdyla3jsx66bmia19wafz1r3ing6ainzz8";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -D rofi-menu-history $out/bin/rofi-menu-history
    install -D rofi-menu-shutdown $out/bin/rofi-menu-shutdown
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
