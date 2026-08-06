# External home-manager modules from flake inputs
# This module re-exports external modules
{ inputs, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];
}
