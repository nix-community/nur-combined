{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  url_key = "community";
  bin = "burpsuite";
  type = "Burp Suite Community Edition";
  hash = "sha256-lV1V92sxCiZ7AGjUNJHO9fkh3aUgt0+oISh7efBaOUA=";
})
