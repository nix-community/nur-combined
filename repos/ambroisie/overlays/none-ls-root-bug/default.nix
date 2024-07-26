self: prev:
{
  vimPlugins = prev.vimPlugins.extend (self.callPackage ./generated.nix { });
}
