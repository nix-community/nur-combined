{ stdenv, lib, fetchFromGitLab, makeWrapper
, coreutils, curl, dtrx, uade123, openmpt123, sidplayfp }:

stdenv.mkDerivation rec {
  pname = "modplay";
  version = "2024-04-05";

  src = fetchFromGitLab {
    owner = "dukzcry";
    repo = "crap";
    rev = "fc462ba5c7f56a739785e6aae639f8d343728312";
    sha256 = "sha256-PWaQCUq7wTGFfj7YC24xKK21RC1Gg16ix6xpy0RDS80=";
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
    homepage = src.meta.homepage;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
