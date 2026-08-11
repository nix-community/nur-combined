{
  pkgs ? import <nixpkgs> { },
}:

let
  scope = pkgs.callPackage ./nix { };
in
scope.gradle2nix.overrideAttrs (attrs: {
  passthru = (attrs.passthru or { }) // {
    inherit (scope) buildGradlePackage buildMavenRepo gradleSetupHook;
  };
})
