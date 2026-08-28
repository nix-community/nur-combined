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
  version = "7.2.0";

  src = fetchFromGitHub {
    owner = "fabioluciano";
    repo = "tmux-powerkit";
    tag = "v${version}";
    hash = "sha256-pwCbe5Q9DJrb8ZhrMVuQCmYeWlx90ZX/sL4cyyoUvyo=";
  };

  meta = {
    description = "Modular tmux status bar framework";
    homepage = "https://github.com/fabioluciano/tmux-powerkit";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
