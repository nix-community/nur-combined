{lib, ...}: {
  home.activation.agentCtrlConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    agent_ctrl_src="$HOME/Configs/agent-ctrl"
    agent_ctrl_dst="$HOME/.agent-ctrl"

    if [ ! -d "$agent_ctrl_src" ]; then
      echo "Agent Ctrl configuration directory not found: $agent_ctrl_src" >&2
      exit 1
    fi

    if [ -e "$agent_ctrl_dst" ] && [ ! -L "$agent_ctrl_dst" ]; then
      echo "Refusing to replace non-symlink Agent Ctrl configuration: $agent_ctrl_dst" >&2
      exit 1
    fi

    ln -sfn "$agent_ctrl_src" "$agent_ctrl_dst"
  '';
}
