{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "volantmq";
  version = "0.4.0-rc.8";

  src = fetchFromGitHub {
    owner = "VolantMQ";
    repo = "volantmq";
    tag = "v${finalAttrs.version}";
    hash = "sha256-c/Ae3wYWzi7btzr8+ia6su7NPtvgjtkTxRyPRJduAcY=";
  };

  vendorHash = "sha256-YLlYOUTli3FXoNC8bUwLXLdwRxRdZ3zPYpE8KwwhuXM=";

  postPatch = ''
    substituteInPlace configuration/init.go --replace-fail "/var/lib" "$out/lib"
  '';

  subPackages = [ "cmd/volantmq" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  postBuild =
    let
      plugins = [
        "debug"
        "health"
        "prometheus"
        "systree"
        "persistence_bbolt"
        "auth_http"
      ];
    in
    ''
      ${lib.concatMapStringsSep "\n" (plugin: ''
        go build -buildmode=plugin -ldflags "${builtins.toString finalAttrs.ldflags}" -o plugins/${plugin}.so
      '') plugins}
    '';

  postInstall = ''
    install -Dm644 plugins/*.so -t $out/lib/volantmq/plugins
  '';

  meta = {
    description = "High-Performance MQTT Server";
    homepage = "https://github.com/VolantMQ/volantmq";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "volantmq";
  };
})
