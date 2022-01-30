{ lib, sources, buildGoModule }:

buildGoModule rec {
  inherit (sources.drone-vault) pname version src;
  vendorSha256 = "sha256-fJ7FrduOudVw5itD3IkIr1MZwm3WEbZizmLJ4IpK0Mc=";
}
