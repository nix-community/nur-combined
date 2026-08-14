{
  lib,
  buildGoModule,
  buildNpmPackage,
  sources,
}:
let
  inherit (sources.hubproxy) src version;

  # The Vue SPA is embedded into the Go binary via `//go:embed all:dist` in
  # src/main.go; vite is configured (web/vite.config.ts) to output the build
  # to `../src/dist`, matching that embed path.
  frontend = buildNpmPackage {
    pname = "hubproxy-web";
    inherit version;
    src = sources.hubproxy.src;
    sourceRoot = "${sources.hubproxy.src.name}/web";

    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/dist
      cp -r ../src/dist/. $out/dist/
      runHook postInstall
    '';
  };
in
buildGoModule (finalAttrs: {
  pname = "hubproxy";
  inherit src version;

  sourceRoot = "${finalAttrs.src.name}/src";

  env.CGO_ENABLED = "0";
  env.GOPROXY = "https://goproxy.cn,direct";
  env.GOSUMDB = "sum.golang.google.cn";

  # Copy the pre-built SPA into the go build root so the unconditional
  # `//go:embed all:dist` directive has assets to embed.
  preBuild = ''
    cp -r ${frontend}/dist ./dist
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  meta = {
    changelog = "https://github.com/sky22333/hubproxy/releases/tag/v${finalAttrs.version}";
    description = "Lightweight multi-purpose proxy for Docker images, GitHub and Hugging Face acceleration";
    homepage = "https://github.com/sky22333/hubproxy";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    mainProgram = "hubproxy";
  };
})
