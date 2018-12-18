{ newScope, wrapper, terraformStubs, pkgs
, name
, src
, filter
, modules
, vars }:

let
  callPackage = newScope self;
  self = rec {
    inherit name src filter vars terraformStubs modules;
    inherit (callPackage ./wrapper {}) wrapper aliases;

    cli   = callPackage ./cli {};
    shell = callPackage ./shell {};

    terraform = pkgs.terraform.withPlugins (plugins: builtins.attrValues (removeAttrs plugins [ "libvirt" ]));
  };
in self
