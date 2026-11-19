{
  lib,
  buildNpmPackage,
  importNpmLock,
  makeWrapper,
  nodejs-slim,
  versionCheckHook,

  sources,
  source ? sources.antigravity-claude-proxy,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;

  nodejs = nodejs-slim;
  nativeBuildInputs = [ nodejs-slim.npm ];

  npmDeps = importNpmLock source.npmDeps;
  npmConfigHook = importNpmLock.npmConfigHook;

  npmInstallFlags = [ "--ignore-scripts" ];

  # Upstream does not bump `version` in package.json; align it with the tag so
  # `acc --version` reports what was packaged.
  postPatch = ''
    node -e '
      const fs = require("fs");
      const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
      pkg.version = process.argv[1];
      fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2) + "\n");
    ' "${finalAttrs.version}"
  '';

  # The dashboard stylesheet is committed; `prepare` would need tailwindcss.
  dontNpmBuild = true;

  # The CLI re-invokes `node` from PATH when launching the server.
  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ finalAttrs.nodejs ]}"
  ];

  # Run the server in the foreground, as a service manager expects, instead of
  # going through the CLI's detached background mode.
  postInstall = ''
    makeWrapper ${lib.getExe finalAttrs.nodejs} $out/bin/antigravity-claude-proxy-server \
      --add-flags "$out/lib/node_modules/${finalAttrs.pname}/src/index.js"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/acc";
  versionCheckProgramArg = "--version";

  meta = {
    description = "Proxy server to use Antigravity's Claude models with Claude Code CLI";
    homepage = "https://github.com/badrisnarayanan/antigravity-claude-proxy";
    changelog = "https://github.com/badrisnarayanan/antigravity-claude-proxy/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "antigravity-claude-proxy";
  };
})
