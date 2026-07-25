{
  lib,
  coredns,
  sources,
  buildGoModule,
  installShellFiles,
  ...
}:
buildGoModule (finalAttrs: {
  inherit (coredns) pname version src;

  patches = [ ./fix-large-axfr.patch ];

  nativeBuildInputs = [ installShellFiles ];

  vendorHash = "sha256-iQiH3sfmnqdxVde2sqpcgmuLwym8w0q4T5xsdnYo5lA=";

  # Override the go-modules fetcher derivation to fetch plugins
  modBuildPhase = ''
    cat > plugin.cfg <<EOF
    # Official plugins (trimmed)
    root:root
    metadata:metadata
    geoip:geoip
    cancel:cancel
    tls:tls
    proxyproto:proxyproto
    quic:quic
    grpc_server:grpc_server
    https:https
    https3:https3
    timeouts:timeouts
    multisocket:multisocket
    reload:reload
    nsid:nsid
    bufsize:bufsize
    bind:bind
    prometheus:metrics
    errors:errors
    log:log
    local:local
    any:any
    loadbalance:loadbalance
    acl:acl
    cache:cache
    dnssec:dnssec
    minimal:minimal
    transfer:transfer
    loop:loop
    forward:forward
    grpc:grpc

    # Custom plugins
    alias:github.com/serverwentdown/alias
    meshname:github.com/zhoreeq/coredns-meshname
    meship:github.com/zhoreeq/coredns-meship
    EOF

    go get github.com/serverwentdown/alias@${sources.coredns-alias.rawVersion}
    go get github.com/zhoreeq/coredns-meshname@${sources.coredns-meshname.rawVersion}
    go get github.com/zhoreeq/coredns-meship@${sources.coredns-meship.rawVersion}

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
