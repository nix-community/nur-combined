{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "fca01eb1e1ad6ba322b05fe1da10f9f5ad48668e";
  sha256 = "sha256-XrMUxlGFVEYmDDSnFajbE4y8OnPPT4/aOB773fGp9RU=";
  version = "unstable-2026-07-07";
  branch = "staging-next";
}
