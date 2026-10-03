{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "c80a207452c7a1fcd7fe3c38f075a4ade96fa286";
  sha256 = "sha256-OpheB/THB9V5nAbU+AYh+AkwjjKTQaBKYRXCVtVXZpQ=";
  version = "unstable-2026-10-02";
  branch = "staging";
}
