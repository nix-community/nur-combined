# An overlay which adds the new attributes to the right places
self: super: {
  haskell =
    super.haskell // ({
      plugins = import ./plugins.nix;
      lib = super.haskell.lib //
              { addPlugin = super.callPackage ./add-plugin.nix {}; };
      overrides =
        sel: sup:
          super.haskell.overrides //
          { withPlugin = import ./with-plugin.nix {hp = sel; haskell = self.haskell; }; }; });
}
