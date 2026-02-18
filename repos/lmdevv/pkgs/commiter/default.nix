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
    rev = "04d997b7b3c006cecc3b7d8575e144a05eabaf53";
    sha256 = "0zw6nv9qaajzrbfp5nfygx3yzichkx6qrfjbk9p4ajqnjhy4c3mv";
  };

  vendorHash = null;

  meta = with lib; {
    description = "CLI tool for generating AI-powered commit messages";
    homepage = "https://github.com/lmdevv/committer";
    license = licenses.mit;
    maintainers = [ "lmdevv" ];
  };
}
