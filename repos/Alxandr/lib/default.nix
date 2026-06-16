{ pkgs, packages }:

let
  inherit (pkgs) lib;

in
{
  nuget-global-tool-update-script = { }: [ (lib.getExe packages.update-nuget-global-tool) ];
}
