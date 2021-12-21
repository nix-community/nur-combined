{ lib, stdenv, fetchFromGitHub, zsh }:

stdenv.mkDerivation rec {
  pname = "zsh-histdb";
  version = "0b63f7c9f6748a1fa65b8d8e4508146da2c59087";

  src = fetchFromGitHub {
    owner = "larkery";
    repo = pname;
    rev = version;
    sha256 = "sha256-gqsd+tW2d/Dyo1IhjSxW6SKsT5dDNvOM1EglzK4UAAM=";
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
