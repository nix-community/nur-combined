{ pkgs }:
{
  inherit (pkgs) zellij;
  azure-cli = pkgs.azure-cli.withExtensions (
    p: with p; [
      azure-devops
      resource-graph
    ]
  );
}
