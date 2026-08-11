{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    opencode
    claude-code
    codex
  ];
}
