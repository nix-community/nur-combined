{
  buildGoModule,
  fetchFromGitHub,
  ...
} @ args:

buildGoModule rec {
  pname = "bird-lg-go";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "bird-lg-go";
    rev = "af5b653326936ede439380d1a88b5ed96e4e7e8c";
    sha256 = "sha256-NURyhXYZjBxzrxGNc2RmWu9s/K5WFXSyRZoiEYhqnqs=";
  };

  vendorSha256 = "101z8afd3wd9ax3ln2jx1hsmkarps5jfzyng4xmvdr4m4hd9basq";

  modRoot = "frontend";
  checkPhase = "";
}
