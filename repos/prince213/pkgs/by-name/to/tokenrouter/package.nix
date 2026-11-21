{
  lib,
  buildGo127Module,
  buildNpmPackage,
  fetchFromGitHub,
  fetchPnpmDeps,

  # nativeBuildInputs
  pnpm_12,
  pnpmConfigHook,

  # nativeInstallCheckInputs
  versionCheckHook,
}:
let
  pnpm = pnpm_12;
in
buildGo127Module (finalAttrs: {
  pname = "tokenrouter";
  version = "0.7.6";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "TokenFlux";
    repo = "TokenRouter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PUDJulWSWvYIHGHroPx0qIDZzJrXtKi4n5qBQbRsRiI=";
  };

  sourceRoot = "${finalAttrs.src.name}/backend";

  patches = [ ./redis-unix-socket.patch ];

  postPatch = ''
    substituteInPlace go.mod \
      --replace-fail \
        "go 1.27.4" \
        "go 1.27.3"
  '';

  preBuild = ''
    cp -r ${finalAttrs.passthru.ui} internal/web/dist
  '';

  overrideModAttrs = _: {
    preBuild = null;
  };

  vendorHash = "sha256-IzpZpexCWcMEt8iBEzvPOjJcbAOv5u3+x7mKwwilO0E=";

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-X main.Version=${finalAttrs.version}"
  ];

  tags = [ "embed" ];

  subPackages = [ "cmd/server" ];

  # no tests
  doCheck = false;

  postInstall = ''
    mv $out/bin/{server,tokenrouter}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    ui = buildNpmPackage (finalAttrs': {
      pname = finalAttrs.pname + "-ui";
      inherit (finalAttrs) version src;

      __structuredAttrs = true;

      sourceRoot = "${finalAttrs'.src.name}/frontend";

      npmDeps = null;
      pnpmDeps = fetchPnpmDeps {
        inherit (finalAttrs')
          pname
          version
          src
          sourceRoot
          ;
        inherit pnpm;
        fetcherVersion = 5;
        hash = "sha256-89j7nAzKzljv6ZpCEEaUa3NR+k9C2ubsZqmWBdEMi14=";
      };

      patches = [ ./redis-unix-socket-ui.patch ];

      postPatch = ''
        substituteInPlace vite.config.ts \
          --replace-fail \
            "outDir: '../backend/internal/web/dist'" \
            "outDir: 'dist'"
      '';

      nativeBuildInputs = [ pnpm ];
      npmConfigHook = pnpmConfigHook;

      npmBuildScript = "build:assets";

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp -r dist/. $out

        runHook postInstall
      '';
    });
  };

  meta = {
    description = "LLM gateway";
    homepage = "https://github.com/TokenFlux/TokenRouter";
    downloadPage = "https://github.com/TokenFlux/TokenRouter/releases";
    changelog = "https://github.com/TokenFlux/TokenRouter/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      lgpl3Plus
      mit
    ];
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "tokenrouter";
  };
})
