self: super: with super.lib; let
  pins = import ../../nix/sources.nix super.path super.targetPlatform.system;
in {
  pythonOverrides = self.lib.buildPythonOverrides (pyself: pysuper: {
    factorio-sat = pyself.callPackage ./factorio-sat.nix { inherit pins; };
    luaparser = pyself.callPackage ./luaparser.nix { inherit pins; };
    usb-resetter = pyself.callPackage ./usb-resetter.nix { inherit pins; };
  }) super.pythonOverrides;
}
