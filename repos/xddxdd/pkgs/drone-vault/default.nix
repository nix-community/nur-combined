{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "drone-vault";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "drone";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-P6rOMqYu6uxGVG1CPNE9fjhntH8IBMyo3mfSOo16EAA=";
  };

  vendorSha256 = "sha256-fJ7FrduOudVw5itD3IkIr1MZwm3WEbZizmLJ4IpK0Mc=";
}
