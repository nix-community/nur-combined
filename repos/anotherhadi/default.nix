{pkgs ? import <nixpkgs> {}}: {
  toutatis = pkgs.python3Packages.callPackage ./pkgs/toutatis {};
  ignorant = pkgs.python3Packages.callPackage ./pkgs/ignorant {};
  ghunt = pkgs.python3Packages.callPackage ./pkgs/ghunt {};
  user-scanner = pkgs.python3Packages.callPackage ./pkgs/user-scanner {};
  github-recon = pkgs.callPackage ./pkgs/github-recon {};
  gravatar-recon = pkgs.callPackage ./pkgs/gravatar-recon {};
  spilltea = pkgs.callPackage ./pkgs/spilltea {};
  usbguard-tui = pkgs.callPackage ./pkgs/usbguard-tui {};
  jwt-tui = pkgs.callPackage ./pkgs/jwt-tui {};
  sheets = pkgs.callPackage ./pkgs/sheets {};
}
