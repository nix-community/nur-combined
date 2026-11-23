{ pkgs }:
{
  inherit (pkgs) rtk zellij;
  nix = pkgs.nixVersions.latest;
  azure-cli = pkgs.azure-cli.withExtensions (
    with pkgs.azure-cli-extensions;
    [
      azure-devops
      resource-graph
    ]
  );
}
