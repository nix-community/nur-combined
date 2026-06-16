{lib, ...}: {
  home.activation.agentCtrlConfig = lib.mkAfter ''
    mkdir -p "$HOME"
    rm -rf "$HOME/.agent-ctrl"
    ln -sfn "$HOME/Configs/agent-ctrl" "$HOME/.agent-ctrl"
  '';
}
