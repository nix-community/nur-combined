{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "e20e029207e36900adf68f05e0ea53d6612dbbeb";
  sha256 = "sha256-XAE2wQSu+JVgLYXJ3tmmwwccWJGwolMMiMrw7KInh90=";
  version = "unstable-2026-09-28";
  branch = "staging-next";
}
