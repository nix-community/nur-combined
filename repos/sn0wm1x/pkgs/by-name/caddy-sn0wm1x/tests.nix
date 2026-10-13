{
  runCommand,
  python3,
  openssl,
  go,
  writableTmpDirAsHomeHook,
  caddy-sn0wm1x,
}:

runCommand "caddy-sn0wm1x-integration-tests"
  {
    __darwinAllowLocalNetworking = true;
    nativeBuildInputs = [
      caddy-sn0wm1x
      python3
      openssl
      go
      writableTmpDirAsHomeHook
    ];
    env = {
      CGO_ENABLED = "0";
      GOTOOLCHAIN = "local";
      GOPROXY = "off";
      GOSUMDB = "off";
      GOFLAGS = "-mod=vendor";
    };
  }
  ''
    export GOCACHE="$TMPDIR/go-cache"
    export GOPATH="$TMPDIR/go"
    cd ${caddy-sn0wm1x.src}
    python3 ${./smoke.py} ${caddy-sn0wm1x}/bin/caddy ${./http3-check.go}
    touch "$out"
  ''
