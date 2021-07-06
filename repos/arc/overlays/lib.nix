self: super: {
  lib = super.lib.extend (self: super: import ../lib {
    inherit super;
    lib = self;
    isOverlayLib = true;
  });
}
