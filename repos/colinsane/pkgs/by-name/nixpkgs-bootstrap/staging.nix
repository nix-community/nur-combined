{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "6ba22d1955e4f5d221810988dd421da994959a55";
  sha256 = "sha256-Zurgu9xdHuMwWPCT2QxfdmVAY5nfb1VpiR9OIhi/8oo=";
  version = "unstable-2026-07-18";
  branch = "staging";
}
