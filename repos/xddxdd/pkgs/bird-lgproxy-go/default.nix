{
  buildGoModule,
  fetchFromGitHub,
  ...
} @ args:

buildGoModule rec {
  pname = "bird-lgproxy-go";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "bird-lg-go";
    rev = "af5b653326936ede439380d1a88b5ed96e4e7e8c";
    sha256 = "sha256-NURyhXYZjBxzrxGNc2RmWu9s/K5WFXSyRZoiEYhqnqs=";
  };

  vendorSha256 = "1viqzzz884rasfrlj4wbq0irkvd6s9jp70qgn5218jriiq4mxdpc";

  modRoot = "proxy";
  checkPhase = "";
}
