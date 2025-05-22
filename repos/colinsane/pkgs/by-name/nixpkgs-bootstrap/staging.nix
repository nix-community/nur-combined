{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "7fd9e08b10ae01283873dd0c935a86b3165dfae4";
  sha256 = "sha256-x6txw8sQkXi0fTFfEDOsPdhA9O/I2heI0L0+jflgcxk=";
  version = "unstable-2025-05-19";
  branch = "staging";
}
