{pkgs, ...}: {
  imports = [
    ./agents.nix
  ];

  environment.systemPackages = [
    pkgs.llmfit # Estimate local model hardware requirements before downloading weights.
    pkgs.rtk # Compact runtime helper used by the agent workflow.
  ];
}
