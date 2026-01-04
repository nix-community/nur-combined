{
  lib,
  coredns,
  unbound,
  sources,
  ...
}:
(coredns.override {
  externalPlugins = [
    {
      name = "mdns";
      repo = "github.com/openshift/coredns-mdns/v4";
      version = sources.coredns-mdns.rawVersion;
    }
    {
      name = "alias";
      repo = "github.com/serverwentdown/alias";
      version = sources.coredns-alias.rawVersion;
    }
    {
      name = "meshname";
      repo = "github.com/zhoreeq/coredns-meshname";
      version = sources.coredns-meshname.rawVersion;
    }
    {
      name = "meship";
      repo = "github.com/zhoreeq/coredns-meship";
      version = sources.coredns-meship.rawVersion;
    }
    {
      name = "unbound";
      repo = "github.com/coredns/unbound";
      version = sources.coredns-unbound.rawVersion;
    }
  ];
  vendorHash = "sha256-kGPET0FxrtCsXCPbT0zy3Mbojb4AC7QaF/bvMzBqy30=";
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
