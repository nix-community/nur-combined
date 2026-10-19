{pkgs ? import <nixpkgs> {}}: {
  operations = pkgs.callPackage ./pkgs/operations {};
  subdomain-finder = pkgs.callPackage ./pkgs/subdomain-finder {};
}
