{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  inherit (pkgs.callPackage ./pkgs/lib { inherit pkgs; }) callPackage;
  modules = import ./modules;
in
{
  inherit modules;
}
// pkgs.lib.recurseIntoAttrs (callPackage ./pkgs/decode { })
// pkgs.lib.recurseIntoAttrs (callPackage ./pkgs/decode-tooling { })
// pkgs.lib.recurseIntoAttrs (callPackage ./pkgs/decode-hardware { })
// pkgs.lib.recurseIntoAttrs (callPackage ./pkgs/vapoursynth { })
// pkgs.lib.recurseIntoAttrs (callPackage ./pkgs/misc { })
