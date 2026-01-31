{
  lib,
  coredns,
  unbound,
  sources,
  buildGoModule,
  installShellFiles,
  ...
}:
buildGoModule (finalAttrs: {
  inherit (coredns) pname version src;

  patches = [ ./fix-large-axfr.patch ];

  buildInputs = [ unbound ];
  nativeBuildInputs = [ installShellFiles ];

  vendorHash = "sha256-CtbppVPELo3KF80tobBp0ag3CvWlA+o9R+O6/dk4aUQ=";

  # Override the go-modules fetcher derivation to fetch plugins
  modBuildPhase = ''
    cat >> plugin.cfg <<EOF
    mdns:github.com/openshift/coredns-mdns/v4
    alias:github.com/serverwentdown/alias
    meshname:github.com/zhoreeq/coredns-meshname
    meship:github.com/zhoreeq/coredns-meship
    unbound:github.com/coredns/unbound
    EOF

    go get github.com/openshift/coredns-mdns/v4@${sources.coredns-mdns.rawVersion}
    go get github.com/serverwentdown/alias@${sources.coredns-alias.rawVersion}
    go get github.com/zhoreeq/coredns-meshname@${sources.coredns-meshname.rawVersion}
    go get github.com/zhoreeq/coredns-meship@${sources.coredns-meship.rawVersion}
    go get github.com/coredns/unbound@${sources.coredns-unbound.rawVersion}

    go mod vendor
    CC= GOOS= GOARCH= go generate
    go mod vendor
    go mod tidy

    mv -t vendor go.mod go.sum plugin.cfg
  '';

  preBuild = ''
    chmod -R u+w vendor
    mv -t . vendor/go.{mod,sum} vendor/plugin.cfg

    CC= GOOS= GOARCH= go generate
  '';

  doCheck = false;

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    homepage = "https://github.com/xddxdd/coredns";
    description = "CoreDNS with Lan Tian's modifications";
    license = lib.licenses.asl20;
    mainProgram = "coredns";
  };
})
