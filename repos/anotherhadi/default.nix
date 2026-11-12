{pkgs ? import <nixpkgs> {}}: {
  cheatmd = pkgs.callPackage ./pkgs/cheatmd {};
  default-creds-tui = pkgs.callPackage ./pkgs/default-creds-tui {};
  github-recon = pkgs.callPackage ./pkgs/github-recon {};
  gravatar-recon = pkgs.callPackage ./pkgs/gravatar-recon {};
  myx = pkgs.callPackage ./pkgs/myx {};
  operations = pkgs.callPackage ./pkgs/operations {};
  proton-vpn-tui = pkgs.callPackage ./pkgs/proton-vpn-tui {};
  revshell = pkgs.callPackage ./pkgs/revshell {};
  settuings = pkgs.callPackage ./pkgs/settuings {};
  spilltea = pkgs.callPackage ./pkgs/spilltea {};
  steep = pkgs.callPackage ./pkgs/steep {};
  usbguard-tui = pkgs.callPackage ./pkgs/usbguard-tui {};
}
