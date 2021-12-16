final: prev:

prev.lib.composeManyExtensions [
  (self: super: {
    vimExtraPlugins = final.lib.makeExtensible (_: self.callPackage ./pkgs/vim-plugins.nix {
      inherit (self.vimUtils) buildVimPluginFrom2Nix;
    });
  })
  (import ./overrides.nix {
    inherit (final) lib;
  })
] final prev
