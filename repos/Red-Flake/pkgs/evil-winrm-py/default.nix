{
  pkgs ? import <nixpkgs> { },
}:
pkgs.callPackage ./package.nix {
  # use Python 3.13 stdlib & package set
  python3Packages = pkgs.python313Packages;

  # build from Git tag v1.5.0
  pyRev = "v1.5.0";

  # provide the C Kerberos library
  libkrb5 = pkgs.krb5;

  # first build prints the wanted hash; paste it here afterwards
  pyHash = "sha256-IACFPPlkgyJh78p6Jy740CQqcySkMTV/8VVPSRJKTPI=";

  # enable Kerberos support
  enableKerberos = true;
}
