# Pure evaluation tests; no derivations are built or sources downloaded.
{ lib }:
let
  policy = import ../lib/ci-policy.nix;
  free = {
    free = true;
  };
  unfree = {
    free = false;
  };
  redistributable = {
    free = false;
    redistributable = true;
  };
  restricted = {
    free = true;
    redistributable = false;
  };
  cases = [
    {
      license = free;
      expected = true;
    }
    {
      license = unfree;
      expected = false;
    }
    {
      license = redistributable;
      expected = true;
    }
    {
      license = restricted;
      expected = false;
    }
    {
      license = [
        free
        free
      ];
      expected = true;
    }
    {
      license = [
        free
        unfree
      ];
      expected = false;
    }
    {
      license = [
        free
        redistributable
      ];
      expected = true;
    }
    {
      license = [ ];
      expected = false;
    }
    {
      license = { };
      expected = false;
    }
    {
      license = "MIT";
      expected = false;
    }
    {
      license = null;
      expected = false;
    }
  ];
  package = name: meta: {
    pname = name;
    version = "1";
    outputs = [
      "out"
      "dev"
    ];
    out = "/nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-${name}";
    dev = "/nix/store/bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb-${name}-dev";
    inherit meta;
  };
  ci = import ../ci.nix {
    pkgs = {
      inherit lib;
      stdenv.hostPlatform = lib.systems.elaborate "x86_64-linux";
    };
    packages = {
      free = package "free" { license = free; };
      unfree = package "unfree" { license = unfree; };
      redistributable = package "redistributable" { license = redistributable; };
      unknown = package "unknown" { };
      local = (package "local" { license = free; }) // {
        preferLocalBuild = true;
      };
      broken = package "broken" {
        license = free;
        broken = true;
      };
      foreign = package "foreign" {
        license = free;
        platforms = [ "aarch64-linux" ];
      };
    };
  };
in
assert builtins.all (case: policy.redistributable case.license == case.expected) cases;
assert
  builtins.attrNames ci.buildPackages == [
    "free"
    "local"
    "redistributable"
    "unfree"
    "unknown"
  ];
assert
  builtins.attrNames ci.cachePackages == [
    "free"
    "local"
    "redistributable"
  ];
assert builtins.length ci.buildOutputs == 10;
assert builtins.length ci.cacheOutputs == 6;
assert (builtins.filter (p: p.name == "unfree") ci.manifest) != [ ];
{
  passed = true;
  licenseCases = builtins.length cases;
}
