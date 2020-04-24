{ buildApp }:
buildApp rec {
  appName = "polls";
  version = "0.10.4";
  url = "https://github.com/nextcloud/polls/releases/download/v${version}/${appName}.tar.gz";
  sha256 = "10h2i1ya1n4vkbd84ak5xcbprzai4nxjsq6b8z097p9fb90rbw4r";
}
