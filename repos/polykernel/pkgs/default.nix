{pkgs ? import <nixpkgs> {}}: {
  zig-master = pkgs.callPackage ./zig {llvmPackages = pkgs.llvmPackages_14;};
  lorien = pkgs.callPackage ./lorien {};
  waylock = pkgs.callPackage ./waylock {};
  i3bar-river = pkgs.callPackage ./i3bar-river {};
  levee = pkgs.callPackage ./levee {};
  kickoff = pkgs.callPackage ./kickoff {};
  wired-notify = pkgs.callPackage ./wired-notify {};
}
