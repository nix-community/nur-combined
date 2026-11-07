{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    opencode
    claude-code
    mempalace
    munder-difflin-bin
  ];

  # LITE MODE: managed settings disabled entirely while sandbox hardening is rolled back.
  # Restore from .local/backups/pre-sandbox-removal-20261005/agents.nix when ready.

  # Managed settings outrank the per-agent `--settings` file that Munder Difflin
  # regenerates on every spawn, so they are the only durable place to override it.
  # Without this, the hive gauge replaces ccstatusline and `gh` runs inside the
  # Claude Code Bash sandbox (no keyring access).
  environment.etc."claude-code/managed-settings.json".text = builtins.toJSON {
    statusLine = {
      type = "command";
      command = "bunx -y ccstatusline@2.2.30";
      padding = 0;
      refreshInterval = 10;
    };
    sandbox.excludedCommands = ["gh"];
  };

  home-manager.sharedModules = [
    ({config, ...}: {
      home.file.".agent-ctrl".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Configs/agent-ctrl";
    })
  ];
}
