{pkgs ? import <nixpkgs> {}}: {
  cargo-compete = pkgs.callPackage ./packages/cargo-compete {};
}
