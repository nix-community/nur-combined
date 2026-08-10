{
  lib,
  buildGoModule,
  sources,
}:
let
  inherit (sources.vertex) version src;
in
buildGoModule (finalAttrs: {
  pname = "vertex";
  inherit version src;

  sourceRoot = "${finalAttrs.src.name}/server";

  vendorHash = "sha256-mfNCIyIGJF5+u5kZrJi+iXjoyao/0l5MfJFxT+Wz6Vs=";

  env.CGO_ENABLED = "0";
  env.GOPROXY = "https://goproxy.cn,direct";
  env.GOSUMDB = "sum.golang.google.cn";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
  ];

  buildPhase = ''
    runHook preBuild
    mkdir -p $out/bin
    go build -ldflags="${toString finalAttrs.ldflags}" -o $out/bin/vertex ./cmd/main
    go build -ldflags="${toString finalAttrs.ldflags}" -o $out/bin/vertex-kernel ./cmd/kernel
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';

  meta = {
    description = "Self-hosted lab manager for one-click container service installation";
    homepage = "https://github.com/vertex-center/vertex";
    changelog = "https://github.com/vertex-center/vertex/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    mainProgram = "vertex";
  };
})
