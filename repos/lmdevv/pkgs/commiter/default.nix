{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "committer";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "lmdevv";
    repo = "committer";
    rev = "f76990553bc5683107f8e55ea473d2cb497ab713";
    sha256 = "sha256-UvNqEwCdwQMwg6q1At1DTWkup9BAJfxZkGCeltk5pGM=";
  };

  vendorHash = null;

  meta = with lib; {
    description = "CLI tool for generating AI-powered commit messages";
    homepage = "https://github.com/lmdevv/committer";
    license = licenses.mit;
    maintainers = [ "lmdevv" ];
  };
}
