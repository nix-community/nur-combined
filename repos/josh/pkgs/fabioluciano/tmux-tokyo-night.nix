{
  lib,
  tmuxPlugins,
  fetchFromGitHub,
  nix-update-script,
}:
tmuxPlugins.mkTmuxPlugin {
  pluginName = "tmux-tokyo-night";
  rtpFilePath = "tmux-tokyo-night.tmux";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "fabioluciano";
    repo = "tmux-tokyo-night";
    rev = "5ce373040f893c3a0d1cb93dc1e8b2a25c94d3da";
    hash = "sha256-9nDgiJptXIP+Hn9UY+QFMgoghw4HfTJ5TZq0f9KVOFg=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    homepage = "https://github.com/fabioluciano/tmux-tokyo-night";
    description = "A Tokyo Night tmux theme directly inspired from Tokyo Night vim theme";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
