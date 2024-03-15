{
  sources,
  lib,
  coredns,
  buildGoModule,
  ...
}@args:
(coredns.override {
  externalPlugins = [
    {
      name = "mdns";
      repo = "github.com/openshift/coredns-mdns";
      version = "latest";
    }
    {
      name = "meshname";
      repo = "github.com/zhoreeq/coredns-meshname";
      version = "latest";
    }
  ];
  vendorHash = "sha256-NFomcVAyxU1PjJnYrSqBI7LagvX/q/ErXfiLb1k++Jo=";
}).overrideAttrs
  (old: {
    patches = (old.patches or [ ]) ++ [ ./fix-large-axfr.patch ];

    meta = with lib; {
      homepage = "https://github.com/xddxdd/coredns";
      description = "CoreDNS with Lan Tian's modifications";
      license = licenses.asl20;
    };
  })
