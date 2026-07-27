{ lib, stdenv, fetchFromGitHub, zsh }:

stdenv.mkDerivation rec {
  pname = "zsh-histdb";
  version = "30797f0c50c31c8d8de32386970c5d480e5ab35d";

  src = fetchFromGitHub {
    owner = "larkery";
    repo = pname;
    rev = version;
    hash = "sha256-PQIFF8kz+baqmZWiSr+wc4EleZ/KD8Y+lxW2NT35/bg=";
  };

  buildInputs = [ zsh ];

  installPhase = ''
    mkdir -p $out/share/zsh-histdb
    cp -r $src/* $out/share/zsh-histdb/
  '';

  meta = with lib; {
    description = "A slightly better history for zsh";
    homepage = "https://github.com/larkery/zsh-histdb";
    license = licenses.mit;
    maintainers = [ maintainers.c0deaddict ];
  };
}
