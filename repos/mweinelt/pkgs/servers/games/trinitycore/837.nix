{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB837.20101";
  commit = "f0a87e11f2668fea1eeb453a76ac03520d109029";
  sha256 = "0yg4d2lal8l0qnq1ykndhlvg0c7wxxz6m8zilz3rn98y5qjsi78i";
})
