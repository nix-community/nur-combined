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
  version = "7.5.1";

  src = fetchFromGitHub {
    owner = "fabioluciano";
    repo = "tmux-powerkit";
    tag = "v${version}";
    hash = "sha256-5KCEBjAH1+dVS5643LbjlzmgS2F9f9jxQm3kOwtTRE4=";
  };

  meta = {
    description = "Modular tmux status bar framework";
    homepage = "https://github.com/fabioluciano/tmux-powerkit";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
