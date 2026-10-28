{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "3048f20c7dac11ac34fa8990adfee67e78b2d002";
  sha256 = "sha256-z9jcxY+LJfQViePjjqIHBKLZPYJAqlw0SlNF3P8oFi8=";
  version = "unstable-2026-10-26";
  branch = "staging";
}
