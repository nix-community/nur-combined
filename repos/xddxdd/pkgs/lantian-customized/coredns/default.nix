{
  lib,
  coredns,
  unbound,
  ...
}:
(coredns.override {
  externalPlugins = [
    {
      name = "mdns";
      repo = "github.com/openshift/coredns-mdns";
      version = "latest";
    }
    {
      name = "alias";
      repo = "github.com/serverwentdown/alias";
      version = "latest";
    }
    {
      name = "meshname";
      repo = "github.com/zhoreeq/coredns-meshname";
      version = "latest";
    }
    {
      name = "meship";
      repo = "github.com/zhoreeq/coredns-meship";
      version = "latest";
    }
    {
      name = "unbound";
      repo = "github.com/coredns/unbound";
      version = "latest";
    }
  ];
  vendorHash = "sha256-lDFWb1M4DDBT35h0IzSJfEUV+YOkicPk0bXysOvvfWY=";
}).overrideAttrs
  (old: {
    patches = (old.patches or [ ]) ++ [ ./fix-large-axfr.patch ];

    buildInputs = (old.buildInputs or [ ]) ++ [ unbound ];

    deleteVendor = true;
    proxyVendor = true;

    preBuild = ''
      rm -rf vendor
      cp -r --reflink=auto "$goModules" vendor
    ''
    + (old.preBuild or "");

    doCheck = false;

    meta = {
      maintainers = with lib.maintainers; [ xddxdd ];
      homepage = "https://github.com/xddxdd/coredns";
      description = "CoreDNS with Lan Tian's modifications";
      license = lib.licenses.asl20;
      mainProgram = "coredns";
    };
  })
