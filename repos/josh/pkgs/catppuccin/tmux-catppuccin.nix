{
  lib,
  tmuxPlugins,
  fetchFromGitHub,
}:
# mkTmuxPlugin discards caller passthru and supplies its own
# nix-update-script updateScript
tmuxPlugins.mkTmuxPlugin rec {
  pluginName = "catppuccin";
  rtpFilePath = "catppuccin.tmux";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "tmux";
    tag = "v${version}";
    hash = "sha256-BIuMmx+UQR3pX692yRYQprpnSYxnusmydHUOVSnbTIU=";
  };

  meta = {
    description = "Soothing pastel theme for Tmux";
    homepage = "https://github.com/catppuccin/tmux";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
