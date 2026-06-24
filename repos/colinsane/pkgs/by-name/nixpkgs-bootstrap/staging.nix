{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "26c33075cf5ae852106bd7c288f22db86e37c9fb";
  sha256 = "sha256-g5j9ufRZk+qe/LASDJ7ZAHmcFIkmqib7r4ImxJXe+A8=";
  version = "unstable-2026-06-24";
  branch = "staging";
}
