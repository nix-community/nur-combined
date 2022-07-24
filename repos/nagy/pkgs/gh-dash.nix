{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "gh-dash";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "dlvhdr";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-y7PJ8BDTiip6cjKQ3CVIcf3LwlGsEj3DHn3EOtCGa4A=";
  };

  vendorSha256 = "sha256-Hk/sBUI2XYB+ZHfuGUR3muEzUtVsGR28EkRD1jKg0Ss=";

  subPackages = [ "." ];

  meta = with lib; {
    description = "gh cli extension to display a dashboard of PRs and issues";
    homepage = "https://github.com/dlvhdr/gh-dash";
    license = licenses.mit;
  };
}
