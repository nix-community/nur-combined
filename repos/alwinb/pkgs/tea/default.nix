{ buildGoModule, fetchzip, lib }:
buildGoModule rec{
  pname = "tea";
  version = "0.6.0";
  src = fetchzip {
    url = "https://gitea.com/gitea/tea/archive/v${version}.zip";
    sha256 = "1aam4r4svmiqpgy0y3kxwj0i0c9c99wm5s7kff66z8vav8697ryx";
  };
  # Tea ships a vendor folder
  vendorSha256 = null;

  meta = {
    description = "The official CLI for Gitea";
    homepage = "https://gitea.com/gitea/tea";
    license = lib.licenses.mit;
  };
}
