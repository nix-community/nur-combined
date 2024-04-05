{ stdenv, lib, fetchFromGitLab, makeWrapper
, coreutils, curl, dtrx, uade123, openmpt123, sidplayfp }:

stdenv.mkDerivation rec {
  pname = "modplay";
  version = "2024-04-05";

  src = fetchFromGitLab {
    owner = "dukzcry";
    repo = "crap";
    rev = "27255fb36fa7f5c955b3e18667b5ffa481269a55";
    sha256 = "sha256-YfubOPWjoWMAOXcY8yuVu3tIKtruSTwnLW583CNHsJg=";
  };

  buildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 modplay/modplay.sh $out/bin/modplay.sh
    install -Dm755 modplay/modplay-shuffle.sh $out/bin/modplay-shuffle.sh
    wrapProgram $out/bin/modplay.sh \
      --prefix PATH : ${lib.makeBinPath [ coreutils curl dtrx uade123 openmpt123 sidplayfp ]}
  '';

  meta = with lib; {
    description = "A quick hack to play tracker music on *nix";
    license = licenses.free;
    homepage = "https://gitlab.com/dukzcry/crap/-/tree/master/modplay";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
