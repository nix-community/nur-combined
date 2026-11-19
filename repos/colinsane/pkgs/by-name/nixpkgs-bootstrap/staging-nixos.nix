{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "a18ae45b90ebdb778da5d82fbe681181f7a96a87";
  sha256 = "sha256-+qrvBYhgOGIvuYuPb/jSkYb6yfUsrFfQDPuYK6Wj0C0=";
  version = "unstable-2026-11-19";
  branch = "staging-nixos";
}
