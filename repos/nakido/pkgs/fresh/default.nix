{
  stdenv,
}:

let
  flake = builtins.getFlake "github:sinelaw/fresh/847946ed0f07ba0b86942ed8b001c213c2cef579"; # v0.2.5
  system = stdenv.hostPlatform.system;
  package = flake.packages.${system}.default;

in
package