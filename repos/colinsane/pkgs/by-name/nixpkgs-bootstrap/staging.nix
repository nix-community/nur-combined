{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "e03646a57ccf401b20fb8373fa38e159a4dfb714";
  sha256 = "sha256-KsgiMHS1tVQ+NALXxXSvrY+iTEpN/HZa0q0QHiC8RAQ=";
  version = "unstable-2026-06-12";
  branch = "staging";
}
