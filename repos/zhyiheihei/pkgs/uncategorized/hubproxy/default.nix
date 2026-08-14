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

    npmDepsHash = "sha256-Jjkjl/3HCoZf/HddV2RLqMs/dxH37DY+ix4bfw6Iddk=";

    # vite's configured outDir (`../src/dist`) points outside the npm build
    # root where the tree is read-only; build into `dist` inside web/ instead.
    buildPhase = ''
      runHook preBuild
      npm run build -- --outDir dist
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/dist
      cp -r dist/. $out/dist/
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

  vendorHash = "sha256-vQLkd/Z9tLNSu9j9HXfaDbrkP5qfQylyqhcg8KEjMOY=";

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
