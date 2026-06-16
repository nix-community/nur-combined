{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "49a170c0da90b8a6a427b0c1566705feb6d76122";
  sha256 = "sha256-wKAnYaTUinsNwTXYsL4gguDbcVkfV8JKq8LGm9k7gmI=";
  version = "unstable-2026-06-14";
  branch = "staging";
}
