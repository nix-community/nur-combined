{
  lib,
  tmuxPlugins,
  fetchFromGitHub,
}:
# mkTmuxPlugin discards caller passthru and supplies its own
# nix-update-script updateScript
tmuxPlugins.mkTmuxPlugin rec {
  pluginName = "tmux-powerkit";
  rtpFilePath = "tmux-powerkit.tmux";
  version = "7.5.0";

  src = fetchFromGitHub {
    owner = "fabioluciano";
    repo = "tmux-powerkit";
    tag = "v${version}";
    hash = "sha256-6EylFN8ZrzmQQTpOGrKChlAKR1fV9G2DCBiXA8eOGFc=";
  };

  meta = {
    description = "Modular tmux status bar framework";
    homepage = "https://github.com/fabioluciano/tmux-powerkit";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
