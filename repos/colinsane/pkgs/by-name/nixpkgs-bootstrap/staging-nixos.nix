{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "9b46a47473f019846daf7c26e5004cc295e471fe";
  sha256 = "sha256-gM+XE0RpTdljfBA976UNoeRjEx75NQQPxv5HfjhRgws=";
  version = "unstable-2026-10-16";
  branch = "staging-nixos";
}
