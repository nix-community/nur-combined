{ lib
, stdenvNoCC
, asp
, bat
, devtools
, git
, gnupg
, makeWrapper
, pacman
, paru-unwrapped
}:

stdenvNoCC.mkDerivation {
  inherit (paru-unwrapped) version;
  pname = "paru";

  nativeBuildInputs = [ makeWrapper ];

  buildCommand = ''
    makeWrapper ${paru-unwrapped}/bin/paru $out/bin/paru \
      --prefix PATH : ${lib.makeBinPath [ asp bat devtools git gnupg pacman ]}
    ln -s ${paru-unwrapped}/{share,etc} $out
  '';

  meta = paru-unwrapped.meta // {
    description = "Feature packed AUR helper";
  };
}