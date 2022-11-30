{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "q";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "natesales";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-M2TgDha+F4hY7f9sabzZEdsxdp8rdXDZB4ktmpDF5D8=";
  };

  vendorSha256 = "sha256-216NwRlU7mmr+ebiBwq9DVtFb2SpPgkGUrVZMUAY9rI=";

  subPackages = [ "." ];

  # network tests
  doCheck = false;

  meta = with lib; {
    description =
      "Tiny command line DNS client with support for UDP, TCP, DoT, DoH, DoQ and ODoH";
    homepage = "https://github.com/natesales/q";
    license = licenses.gpl3;
  };
}
