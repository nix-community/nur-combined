{ buildApp }:
buildApp rec {
  appName = "apporder";
  version = "0.8.0";
  url = "https://github.com/juliushaertl/apporder/releases/download/v${version}/${appName}.tar.gz";
  sha256 = "04wlvhdngn3fkvphaply9lycvmfy6294pzpvccvkj2m8ihbdnigw";
}
