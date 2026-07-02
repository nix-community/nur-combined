{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "12425f1be9fe948a0baa4313914fdd8a1569bc25";
  sha256 = "sha256-TmcRqYEIoGSPwdzSnevXGsw7ZbEcyaBCjzRVFTjxzn0=";
  version = "unstable-2026-07-01";
  branch = "staging";
}
