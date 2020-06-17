{ stdenv
, fetchFromGitHub
, makeWrapper
, bash
, coreutils
, ripgrep
, jq
}:
let
  path = [
    bash
    coreutils
    ripgrep
  ];
in
stdenv.mkDerivation rec {
  name = "nix-search";

  src = ./src;

  installPhase = ''
    mkdir -p $out/bin
    install $src/nix-search.sh $out/bin/nix-search
    wrapProgram $out/bin/nix-search \
      --prefix PATH : ${ stdenv.lib.makeBinPath path }
  '';

  nativeBuildInputs = [ makeWrapper ];

  meta = with stdenv.lib; {
    description = "Command line util for accelerated package search in nix environments";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
