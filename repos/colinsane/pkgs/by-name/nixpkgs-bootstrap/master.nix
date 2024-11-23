{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "1f8150661e78f70bda0b51893344326fc2ca264c";
  sha256 = "sha256-Mrt4opMsoBdT1vq3hkkh/Ibm1ZX5WjHKU089EtgeiAU=";
  version = "0-unstable-2024-11-22";
  branch = "master";
}
