{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "gh-dash";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "dlvhdr";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-hksqcawZ1DCnaOtuPNUjsCtjRtEVJXFu41xLn+ddJ3k=";
  };

  vendorSha256 = "sha256-knfRrwXy6sGvzouyCk6i7nZ1ZrOBfs6yOLq2l5ynxoY=";

  subPackages = [ "." ];

  meta = with lib; {
    description = "gh cli extension to display a dashboard of PRs and issues";
    homepage = "https://github.com/dlvhdr/gh-dash";
    license = licenses.mit;
  };
}
