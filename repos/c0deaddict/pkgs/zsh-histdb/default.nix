{ stdenv, fetchFromGitHub, zsh }:

stdenv.mkDerivation rec {
  pname = "zsh-histdb";
  version = "4274de7c1bca84f440fb0125e6931c1f75ad5e29";

  src = fetchFromGitHub {
    owner = "larkery";
    repo = pname;
    rev = version;
    sha256 = "1zh3r090jh6n6xwb4d2qvrhdhw35pc48j74hvkwsq06g62382zk3";
  };

  buildInputs = [ zsh ];

  installPhase = ''
    mkdir -p $out/share/zsh-histdb
    cp -r $src/* $out/share/zsh-histdb/
  '';

  meta = with stdenv.lib; {
    description = "A slightly better history for zsh";
    homepage = "https://github.com/larkery/zsh-histdb";
    license = licenses.mit;
    maintainers = [ maintainers.c0deaddict ];
  };
}
