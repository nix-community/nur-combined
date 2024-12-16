{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "a36414b569020d1ca603e160229ef160d288b237";
  sha256 = "sha256-e1rAHoAGkZEf3sGdvgcwfGySbMN2uSiYJf5IVDgFC7A=";
  version = "0-unstable-2024-12-16";
  branch = "staging";
}
