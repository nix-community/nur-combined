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
    rev = "6481e7cc8d9efadb066aa76e29969da1f59bd411";
    sha256 = "0zdf08r2nnvrpqg6dn45ad4672yzdap7vsd59963p269f12yvllm";
  };

  vendorSha256 = "101z8afd3wd9ax3ln2jx1hsmkarps5jfzyng4xmvdr4m4hd9basq";

  modRoot = "frontend";
  checkPhase = "";
}
