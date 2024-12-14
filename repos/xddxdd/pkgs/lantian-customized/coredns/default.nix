{ lib, coredns, ... }:
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
  vendorHash = "sha256-9ANArRIJR6R2SmVkK8NbPzh4d+2YpLkJ+fB0TfirUIU=";
}).overrideAttrs
  (old: {
    patches = (old.patches or [ ]) ++ [ ./fix-large-axfr.patch ];

    doCheck = false;

    meta = {
      maintainers = with lib.maintainers; [ xddxdd ];
      homepage = "https://github.com/xddxdd/coredns";
      description = "CoreDNS with Lan Tian's modifications";
      license = lib.licenses.asl20;
      mainProgram = "coredns";
    };
  })
