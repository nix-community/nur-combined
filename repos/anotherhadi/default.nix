{pkgs ? import <nixpkgs> {}}: {
  github-recon = pkgs.callPackage ./pkgs/github-recon {};
  gravatar-recon = pkgs.callPackage ./pkgs/gravatar-recon {};
  spilltea = pkgs.callPackage ./pkgs/spilltea {};
  settuings = pkgs.callPackage ./pkgs/settuings {};
  usbguard-tui = pkgs.callPackage ./pkgs/usbguard-tui {};
  jwt-tui = pkgs.callPackage ./pkgs/jwt-tui {};
  fztea = pkgs.callPackage ./pkgs/fztea {};
  monitui = pkgs.callPackage ./pkgs/monitui {};
  revshell = pkgs.callPackage ./pkgs/revshell {};
}
