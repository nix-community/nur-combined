{ pkgs }:
{
  inherit (pkgs) zellij;
  azure-cli = pkgs.azure-cli.withExtensions (
    with pkgs.azure-cli-extensions;
    [
      azure-devops
      resource-graph
    ]
  );
}
