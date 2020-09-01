{ stdenv, lib, makeWrapper, fetchFromGitHub, gnused, jq }:

stdenv.mkDerivation rec {
  pname = "rofi-menu";
  version = "0.1.1.0";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = pname;
    rev = version; 
    sha256 = "0xcf571v8bkq01hkx7nf955fck38avcp6d31n27ni6c59slqhbgn";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -D rofi-menu-history $out/bin/rofi-menu-history
  '';

  postFixup = ''
    wrapProgram $out/bin/rofi-menu-history --prefix PATH : ${lib.makeBinPath [ gnused jq ]}
  '';

  meta = with stdenv.lib; {
    description = "Various rofi menus (aka. modi)";
    homepage = "https://github.com/emmanuelrosa/rofi-menu";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
