{ fetchFromGitHub, lib, stdenv }:

stdenv.mkDerivation {
  pname = "zsh-abbr";
  version = "4.5.0"; # Note: 4.6.0 introduces noncommercial license

  src = fetchFromGitHub {
    owner = "olets";
    repo = "zsh-abbr";
    rev = "f10935fe3b08b990259bede5e481cc392848cae5";
    hash = "sha256-X4a1HVuEYChd0pXd45l5UKDItlpRksVQpfwJbiMmSlI=";
  };

  dontBuild = true;

  installPhase = ''
    install -D -t $out/share/zsh/plugins/zsh-abbr \
      zsh-abbr.zsh \
      zsh-abbr.plugin.zsh
  '';

  meta = {
    description = "Manager of auto-expanding abbreviations for Zsh";
    homepage = "https://github.com/olets/zsh-abbr";
    license = lib.licenses.mit;
  };
}
