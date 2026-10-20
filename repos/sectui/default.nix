{pkgs ? import <nixpkgs> {}}: {
  cheatmd = pkgs.callPackage ./pkgs/cheatmd {};
  operations = pkgs.callPackage ./pkgs/operations {};
  subdomain-finder = pkgs.callPackage ./pkgs/subdomain-finder {};
}
