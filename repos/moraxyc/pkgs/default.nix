# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
# mode:
# - null: Default mode
# - "ci": from Garnix CI
# - "nur": from NUR bot
mode: { pkgs ? import <nixpkgs> { }
      , inputs ? null
      , ...
      }:
let
  inherit (pkgs) lib;

  ifNotCI = p:
    if mode == "ci"
    then null
    else p;

  ifNotNUR = p:
    if mode == "nur"
    then null
    else p;

  mkScope = f:
    builtins.removeAttrs
      (lib.makeScope pkgs.newScope (self:
        let
          pkg = self.newScope {
            inherit mkScope;
            sources = self.callPackage ../_sources/generated.nix { };
          };
        in
        f self pkg))
      [
        "newScope"
        "callPackage"
        "overrideScope"
        "overrideScope'"
        "packages"
      ];
in
mkScope (self: pkg:
let
  # Wrapper will greatly increase NUR evaluation time. Disable on NUR to stay within 15s time limit.
in
{
  # Package groups

  boringssl-oqs = pkg ./boringssl-oqs { };
  liboqs = pkg ./liboqs { };
  openssl-oqs-provider = pkg ./openssl-oqs-provider { };
  nezha-agent = pkg ./nezha-agent { };
})
