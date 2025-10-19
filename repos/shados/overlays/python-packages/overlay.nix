final: prev:
let
  pins = import ../../nix/sources.nix prev.path prev.targetPlatform.system;
in
{
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyfinal: pyprev: {
      factorio-sat = pyfinal.callPackage ./factorio-sat.nix { inherit pins; };
      luaparser = pyfinal.callPackage ./luaparser.nix { inherit pins; };
      usb-resetter = pyfinal.callPackage ./usb-resetter.nix { inherit pins; };
    })
  ];
}
