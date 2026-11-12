{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "42f5f393ba68b17e82e9614c33f72237a445b7cd";
  sha256 = "sha256-iXJVbLyfurvNDytfWQ4wcV0H2+p/WJP198ZKn/YODOU=";
  version = "unstable-2026-11-06";
  branch = "staging-nixos";
}
