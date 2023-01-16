{ lib
, buildGoModule
, fetchFromGitHub }:

buildGoModule rec {
  pname = "kubectl-realname-diff";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "hhiroshell";
    repo = "kubectl-realname-diff";
    rev = "v${version}";
    sha256 = "sha256-H9+a7nb90AI2VUiii0LbDdik+Ihe1blSdLYwJRVRE8w=";
  };

  vendorSha256 = "sha256-Hw7f9nJvcslr6wbmjz9XtMxAm2XYVb4yhW2LssQOxrQ=";

  doCheck = false;
  subPackages = [ "cmd/kubectl-realname_diff" ];

  meta = with lib; {
    description = "A kubectl plugin that diffs live and local resources ignoring Kustomize hash-suffixes";
    homepage = "https://github.com/hhiroshell/kubectl-realname-diff/";
    license = licenses.asl20;
    maintainers = with maintainers; [ tboerger ];
  };
}
