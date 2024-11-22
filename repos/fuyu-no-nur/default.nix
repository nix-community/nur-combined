{pkgs ? import <nixpkgs> {}}: {
  samsung-volatile = pkgs.callPackage ./pkgs/samsung-volatile {};
}
