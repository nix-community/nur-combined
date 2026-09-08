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
  version = "7.4.0";

  src = fetchFromGitHub {
    owner = "fabioluciano";
    repo = "tmux-powerkit";
    tag = "v${version}";
    hash = "sha256-2nBOxV/56R/z1lAN6QunoV/w3kEQ/CJXf2lpMT6n5Zw=";
  };

  meta = {
    description = "Modular tmux status bar framework";
    homepage = "https://github.com/fabioluciano/tmux-powerkit";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
