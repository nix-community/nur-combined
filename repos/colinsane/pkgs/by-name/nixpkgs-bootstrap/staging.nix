{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "e7344062a548594feadbccc661322ed5d079ed92";
  sha256 = "sha256-HOkHAxQw22kpEgPNwdvgAFpKplC/+DYGS/erDgg/hb0=";
  version = "0-unstable-2024-12-30";
  branch = "staging";
}
