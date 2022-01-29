{ buildGoModule, fetchzip, lib }:
buildGoModule rec{
  pname = "tea";
  version = "0.8.0";
  src = fetchzip {
    url = "https://gitea.com/gitea/tea/archive/v${version}.zip";
    sha256 = "sha256-LtLel6JfmYr2Zu7g7oBjAqDcl5y7tJL3XGL7gw+kHxU=";
  };
  # Tea ships a vendor folder
  vendorSha256 = null;

  meta = {
    description = "The official CLI for Gitea";
    homepage = "https://gitea.com/gitea/tea";
    license = lib.licenses.mit;
  };
}
