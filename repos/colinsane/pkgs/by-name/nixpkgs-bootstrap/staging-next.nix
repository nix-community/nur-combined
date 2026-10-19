{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "108443ce3f6ae3bb99970a067be192c6e6c21b97";
  sha256 = "sha256-I9vkg/OjzJ71WVOXa/33/sAqY8n+sbZRGZ5SFPLqlNk=";
  version = "unstable-2026-10-18";
  branch = "staging-next";
}
