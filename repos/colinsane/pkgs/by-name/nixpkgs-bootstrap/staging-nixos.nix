{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "f64207529e70a16f57ba2f7eabe7c037579b5359";
  sha256 = "sha256-I5MhTsKQt2G2sxSnvTvVCZD0X4W2TmH4G7qUM8l6HBc=";
  version = "unstable-2026-10-02";
  branch = "staging-nixos";
}
