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
  vendorHash = "sha256-bV8Gn2XoRGpFFxaXmUm4PvWmznslmpl66ucyJLib8Zg=";
}).overrideAttrs
  (old: {
    patches = (old.patches or [ ]) ++ [ ./fix-large-axfr.patch ];

    buildInputs = (old.buildInputs or [ ]) ++ [ unbound ];

    doCheck = false;

    meta = {
      maintainers = with lib.maintainers; [ xddxdd ];
      homepage = "https://github.com/xddxdd/coredns";
      description = "CoreDNS with Lan Tian's modifications";
      license = lib.licenses.asl20;
      mainProgram = "coredns";
    };
  })
