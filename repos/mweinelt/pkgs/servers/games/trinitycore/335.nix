{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.21061";
  commit = "27c338a268abfe13a9f251c1b4eb18c9ba14ebea";
  branch = "3.3.5";
  sha256 = "08dvy4srzsyczqi8hzsx5s7zy6vs62qc2idcvbh523ys7xislc8k";
})
