{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "d8ee6ee45b4a48fd1a9acb18ddba36fc19030a29";
  sha256 = "sha256-jyUeYp1CV8jmL8PgZ9td5MlPeXff+fxxU7Tf63i0bic=";
  version = "unstable-2026-06-11";
  branch = "staging-next";
}
