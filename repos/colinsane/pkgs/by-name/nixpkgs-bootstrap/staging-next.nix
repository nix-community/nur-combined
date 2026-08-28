{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "74e72aa3558404d83621d937963b70250d5bb7e2";
  sha256 = "sha256-2+5zw3nIvcRiXqMQ1zdW6qmsJquEaLAaeN41I9zysMk=";
  version = "unstable-2026-08-28";
  branch = "staging-next";
}
