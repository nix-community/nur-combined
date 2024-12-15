{pkgs ? import <nixpkgs> {}}: {
  samsung-volatile = pkgs.callPackage ./pkgs/samsung-volatile {};
  samsung-galaxybook-extras = pkgs.callPackage ./pkgs/samsung-galaxybook-extras {};
}
