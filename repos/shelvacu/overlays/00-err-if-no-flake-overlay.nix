self: super:
if super ? hasVacuFlakeOverlay then
  { }
else
  builtins.throw "overlays in shelvacu/nix-stuff can't be used without overlays from flake.nix"
