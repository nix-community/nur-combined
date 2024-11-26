{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "4f8a186b2b9dc4fa07fc2e77519732fddcdc7502";
  sha256 = "sha256-aRGyfGEyl1wHlEhe+HRKKVh0E8PDqF7/djEksK1hlsY=";
  version = "0-unstable-2024-11-25";
  branch = "staging";
}
