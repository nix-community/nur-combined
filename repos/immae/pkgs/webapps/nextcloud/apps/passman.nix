{ buildApp }:
buildApp rec {
  # FIXME: it creates a /settings/user/additional setting url which
  # doesn’t work
  appName = "passman";
  version = "2.3.4";
  url = "https://releases.passman.cc/${appName}_${version}.tar.gz";
  sha256 = "004bgdbz6ks0zizgx6gw6m60g30m1xclw4fakbh6qq1n8sxpdqsq";
}
