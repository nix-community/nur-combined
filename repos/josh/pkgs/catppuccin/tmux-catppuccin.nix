{
  lib,
  tmuxPlugins,
  fetchFromGitHub,
  nix-update-script,
}:
tmuxPlugins.mkTmuxPlugin rec {
  pluginName = "catppuccin";
  rtpFilePath = "catppuccin.tmux";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "tmux";
    tag = "v${version}";
    hash = "sha256-3CJRQCgS8NAN7vOLBjNGiHbGXTIrIyY/FLmfZrXcEYc=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Soothing pastel theme for Tmux";
    homepage = "https://github.com/catppuccin/tmux";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
