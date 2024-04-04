self: super: with super.lib; let
  pins = import ../../nix/sources.nix super.path super.targetPlatform.system;
in {
  pythonOverrides = self.lib.buildPythonOverrides (pyself: pysuper: {
    usb-resetter = pyself.callPackage ./usb-resetter.nix { inherit pins; };
  }) super.pythonOverrides;
}
