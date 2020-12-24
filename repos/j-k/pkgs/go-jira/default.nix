{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "go-jira";
  version = "1.0.27";

  src = fetchFromGitHub {
    owner = "go-jira";
    repo = "jira";
    rev = "v${version}";
    sha256 = "1sw56aqghfxh88mfchf0nvqld0x7w22jfwx13pd24slxv1iag1nb";
  };

  vendorSha256 = "0d64gkkzfm6hbgqaibj26fpaqnjs50p1675ycrshdhn6blb5mbxg";

  subPackages = [ "cmd/jira" ];

  buildFlagsArray = [
    "-ldflags="
    "-s"
    "-w"
    "-X github.com/go-jira/jira.VERSION=v${version}"
  ];

  meta = with lib; {
    description = "Simple command line client for Atlassian's Jira service written in Go";
    homepage = src.meta.homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
  };
}
