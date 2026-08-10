{
  lib,
  buildGoModule,
  sources,
}:
buildGoModule (finalAttrs: {
  pname = "docker-proxy";
  inherit (sources.docker-proxy) version src;

  sourceRoot = "${finalAttrs.src.name}/go-proxy";

  vendorHash = "sha256-g+yaVIx4jxpAQ/+WrGKxhVeliYx7nLQe/zsGpxV4Fn4=";

  env.CGO_ENABLED = "0";
  env.GOPROXY = "https://goproxy.cn,direct";
  env.GOSUMDB = "sum.golang.google.cn";

  buildPhase = ''
    runHook preBuild
    mkdir -p $out/bin
    go build -trimpath -ldflags="-s -w -buildid=" -o $out/bin/registry-proxy .
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec $out/share/docker-proxy
    mv $out/bin/registry-proxy $out/libexec/registry-proxy
    install -Dm644 config.yaml $out/share/docker-proxy/config.yaml
    cat > $out/bin/docker-proxy <<EOF
    #!/bin/sh
    DATA_DIR="\''${DOCKER_PROXY_DATA_DIR:-\''${XDG_DATA_HOME:-\$HOME/.local/share}/docker-proxy}"
    mkdir -p "\$DATA_DIR"
    CONFIG_FILE="\''${DOCKER_PROXY_CONFIG_FILE:-\$DATA_DIR/config.yaml}"
    if [ ! -f "\$CONFIG_FILE" ]; then
      mkdir -p "\$(dirname "\$CONFIG_FILE")"
      cp $out/share/docker-proxy/config.yaml "\$CONFIG_FILE"
    fi
    exec $out/libexec/registry-proxy "\$CONFIG_FILE" "\$@"
    EOF
    chmod +x $out/bin/docker-proxy
    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/dqzboy/Docker-Proxy/releases/tag/v${finalAttrs.version}";
    description = "Self-hosted Docker registry proxy with host-based upstream routing";
    homepage = "https://github.com/dqzboy/Docker-Proxy";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    mainProgram = "docker-proxy";
  };
})
