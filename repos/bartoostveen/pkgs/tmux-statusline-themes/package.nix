{
  lib,
  tmuxPlugins,
  fetchFromGitHub,
  nix-update-script,
}:

tmuxPlugins.mkTmuxPlugin {
  pluginName = "tmux-statusline-themes";
  version = "0-unstable-2022-04-20";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "dmitry-kabanov";
    repo = "tmux-statusline-themes";
    rev = "5239a3b8d0de860ef573a688678c64a47d3d431f";
    hash = "sha256-A4PxrkUGZHjIt0np95848quUo42i+4CX9LwOJ5ek0/Y=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=main" ]; };

  meta = {
    description = "Tmux plugin that contains several themes for tmux status line";
    homepage = "https://github.com/dmitry-kabanov/tmux-statusline-themes";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bartoostveen ];
  };
}
