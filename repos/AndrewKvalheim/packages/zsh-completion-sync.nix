{ fetchFromGitHub
, gitUpdater
, lib
, stdenv
}:

stdenv.mkDerivation (zsh-completion-sync: {
  pname = "zsh-completion-sync";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "BronzeDeer";
    repo = "zsh-completion-sync";
    rev = "v${zsh-completion-sync.version}";
    hash = "sha256-zDlmFaKU/Ilzcw6o22Hu9JFt8JKsER8idkb6QrtQKjI=";
  };

  dontBuild = true;

  installPhase = ''
    install -D -t "$out/share/zsh/plugins/zsh-completion-sync" \
      'zsh-completion-sync.plugin.zsh'
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Zsh plugin that automatically loads completions added dynamically to FPATH or XDG_DATA_DIRS";
    homepage = "https://github.com/BronzeDeer/zsh-completion-sync";
    license = lib.licenses.asl20;
  };
})
