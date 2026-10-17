{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "130d73e45507326682afd80722cd59cb704efc20";
  sha256 = "sha256-EotXAPR+Kgpz36rOMluU59hydGXZ578Ze+UxJqy47Kc=";
  version = "unstable-2026-10-16";
  branch = "staging-next";
}
