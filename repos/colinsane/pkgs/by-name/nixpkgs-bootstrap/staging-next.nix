{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "31504d32fec77cca58ef68fe2e465d61be4a80b3";
  sha256 = "sha256-NlzjPCMdgilDuiF7jt/yEGQintXUhVzBrzXFsWbrXMU=";
  version = "unstable-2025-12-05";
  branch = "staging-next";
}
