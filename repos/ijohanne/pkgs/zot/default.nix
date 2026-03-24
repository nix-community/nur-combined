{ sources, pkgs, ... }:
let
  zui = pkgs.fetchurl {
    url = "https://github.com/project-zot/zui/releases/download/commit-111cb8e/zui.tgz";
    hash = "sha256-cuiUi764XHZZlR1JrkCSvnrkx6XvKvyHgFctCWK/a6g=";
  };
in
pkgs.buildGoModule {
  pname = "zot";
  version = "2.1.15";
  src = sources.zot;
  vendorHash = "sha256-AhzrYlRE1trshVtXKLiOcwSZzdd8SSDuPz9BNKuwRFs=";
  doCheck = false;

  env = {
    CGO_ENABLED = "0";
    GOEXPERIMENT = "jsonv2";
  };

  preBuild = ''
    tar xzf ${zui} -C pkg/extensions/
  '';

  tags = [
    "sync"
    "search"
    "scrub"
    "metrics"
    "lint"
    "ui"
    "mgmt"
    "profile"
    "userprefs"
    "imagetrust"
    "events"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X zotregistry.dev/zot/v2/pkg/api/config.ReleaseTag=v2.1.15"
    "-X zotregistry.dev/zot/v2/pkg/api/config.BinaryType=zot-full"
  ];

  subPackages = [
    "cmd/zot"
    "cmd/zli"
  ];

  meta = {
    description = "OCI-native container registry";
    homepage = "https://zotregistry.dev";
    license = pkgs.lib.licenses.asl20;
  };
}
