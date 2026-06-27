{ pkgs, ... }:
{
  sane.programs.serena = {
    packageUnwrapped = pkgs.mcp-servers-nix.packages.serena;
    sandbox.method = null;  #< TODO: sandbox
  };
}
