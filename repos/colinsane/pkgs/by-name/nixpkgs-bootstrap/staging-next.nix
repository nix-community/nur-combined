{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "20d1b508c197e854f4c160d1b3d6091e545a536b";
  sha256 = "sha256-p4rf6+UYaYfjVlacM9AzrZQ0ViosXmoQfjJKa4WvH6E=";
  version = "0-unstable-2024-12-30";
  branch = "staging-next";
}
