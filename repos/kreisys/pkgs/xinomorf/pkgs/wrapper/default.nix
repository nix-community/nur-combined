{ newScope, terraformStubs, terraform
, name
, src
, filter
, modules
, vars }:

let
  callPackage = newScope self;
  self = rec {
    inherit name src filter vars terraformStubs modules terraform;
    wrapper = callPackage ./wrapper.nix {};
    aliases = callPackage ./aliases.nix {};
  };
in self
