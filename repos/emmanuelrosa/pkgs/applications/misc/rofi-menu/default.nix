{ stdenv, lib, makeWrapper, fetchFromGitHub, gnused, jq }:

stdenv.mkDerivation rec {
  pname = "rofi-menu";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = pname;
    rev = version; 
    sha256 = "1pbgy0cjsml8d8hs78py3i4f0j2ad1zn4j633cs13sc7pq9cxy6c";
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
