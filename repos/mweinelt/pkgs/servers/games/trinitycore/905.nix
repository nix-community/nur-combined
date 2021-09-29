{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB905.21071";
  commit = "6b8bb270a8b316504289dad654e5aef88cd8d27f";
  sha256 = "189spfwkg2csxr582adkrki0pnzc9qq50n125pc48x3mv5zv4rl5";
})
