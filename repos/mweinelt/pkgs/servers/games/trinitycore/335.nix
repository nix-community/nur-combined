{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.21041";
  commit = "2fcf455b34e1ab7c5cf143d747d0c88dd20592c0";
  branch = "3.3.5";
  sha256 = "1mkyk0rrxj5lxvcls1kzbclzjywa8ar37clbsyf702600qc1l0aj";
})
