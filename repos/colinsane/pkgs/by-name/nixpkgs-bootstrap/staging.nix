{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "77543b70184aae72c49dbdef0e7f4e718cd65060";
  sha256 = "sha256-Fr2V9VsEbJNZAJ+qIGN5BuMkKj/zKT18fDUHosFbK60=";
  version = "unstable-2026-10-17";
  branch = "staging";
}
