{
  fetchzip,
  lib,
  makeWrapper,
  nix-update-script,
  nodejs,
  stdenvNoCC,
}:

# upstream builds with gn/ninja on top of devtools-frontend's chromium tooling,
# which needs gclient to fetch prebuilt toolchains. use the published npm
# package instead, it is fully bundled and has no runtime dependencies
stdenvNoCC.mkDerivation (final: {
  pname = "chrome-devtools-mcp";
  version = "1.13.0";

  src = fetchzip {
    url = "https://registry.npmjs.org/chrome-devtools-mcp/-/chrome-devtools-mcp-${final.version}.tgz";
    hash = "sha256-Tq62vmf6Z2OxG7cQ+PYuI5OYrBVeUbfkGGPXFrhb3L8=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/chrome-devtools-mcp
    cp -r . $out/lib/node_modules/chrome-devtools-mcp

    for bin in chrome-devtools-mcp chrome-devtools; do
      makeWrapper ${lib.getExe nodejs} $out/bin/$bin \
        --add-flags $out/lib/node_modules/chrome-devtools-mcp/out/Default/gen/src/bin/$bin.js
    done

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    [[ "$($out/bin/chrome-devtools-mcp --version)" == "${final.version}" ]]
    $out/bin/chrome-devtools --help > /dev/null

    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      final.pname
    ];
  };

  meta = {
    mainProgram = "chrome-devtools-mcp";
    description = "Chrome DevTools for coding agents";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    homepage = "https://github.com/ChromeDevTools/chrome-devtools-mcp";
    changelog = "https://github.com/ChromeDevTools/chrome-devtools-mcp/releases/tag/v${final.version}";
  };
})
