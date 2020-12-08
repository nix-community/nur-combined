{ stdenv
, fetchFromGitHub
, installShellFiles

, zsh
}:

stdenv.mkDerivation {
  pname = "zsh-z";
  version = "2020.09.19.09209db";

  src = fetchFromGitHub {
    owner = "agkozak";
    repo = "zsh-z";
    rev = "09209db2daf4b0e7f180cea04d1344fcc06a9410";
    sha256 = "06z96v3w998hcws13lj6332154aqg1qg3ignv2x835frq677yfzm";
  };

  nativeBuildInputs = [ installShellFiles ];

  propogatedBuildInputs = [ zsh ];

  installPhase = ''
    install -D zsh-z.plugin.zsh \
      $out/share/zsh-z/zsh-z.zsh
    installShellCompletion --zsh _zshz
  '';

  meta = {
    description = ''Jump quickly to directories that you have visited "frecently." A native ZSH port of z.sh.'';
    homepage = "https://github.com/agkozak/zsh-z";
    license = stdenv.lib.licenses.mit;
  };
}
