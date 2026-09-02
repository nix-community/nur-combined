{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "31e809f2911cf9b1ccc26be3ebf06a5cc7d8b4ac";
  sha256 = "sha256-dSXcwNh78PiZC6woNgOJQ6JzXyRLrxDaJUMygseNTXA=";
  version = "unstable-2026-09-01";
  branch = "staging";
}
