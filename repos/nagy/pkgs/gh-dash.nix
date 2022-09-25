{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "gh-dash";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "dlvhdr";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-fgafubFMYkWEqYVC9aHhheJQO8DnHB9onS1NJ63g74Y=";
  };

  vendorSha256 = "sha256-BbrHvphTQLvUKanmO4GrNpkT0MSlY7+WMJiyXV7dFB8=";

  subPackages = [ "." ];

  meta = with lib; {
    description = "gh cli extension to display a dashboard of PRs and issues";
    homepage = "https://github.com/dlvhdr/gh-dash";
    license = licenses.mit;
  };
}
