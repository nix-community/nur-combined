self: super: import ./. {
  inherit super;
  lib = self;
  isOverlayLib = true;
}
