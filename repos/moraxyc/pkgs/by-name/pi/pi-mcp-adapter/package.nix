{
  lib,
  buildNpmPackage,
  importNpmLock,

  sources,
  source ? sources.pi-mcp-adapter,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) src version pname;

  npmDeps = importNpmLock {
    package =
      let
        package = lib.importJSON source.extract."package.json";
      in
      package
      // {
        # Only the compiler is needed to build.
        devDependencies = lib.getAttrs [ "typescript" ] package.devDependencies;
      };
    packageLock =
      let
        lock = lib.importJSON source.extract."package-lock.json";
      in
      lock
      // {
        packages = lib.filterAttrs (
          name: package: !(package.dev or false) || name == "node_modules/typescript"
        ) lock.packages;
      };
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  npmFlags = [ "--legacy-peer-deps" ];

  # Rebuild the committed dist/ that cli.js and the public subpath exports load.
  postPatch = ''
    rm -rf dist
  '';

  # Type checking needs the Pi dev dependencies, which the host provides at runtime.
  buildPhase = ''
    runHook preBuild

    node_modules/.bin/tsc -p tsconfig.public.json --noCheck

    runHook postBuild
  '';
  npmPackFlags = [ "--ignore-scripts" ];

  postInstall = ''
    mv $out/lib/node_modules/pi-mcp-adapter $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules
    substituteInPlace $out/bin/pi-mcp-adapter \
      --replace-fail "$out/lib/node_modules/pi-mcp-adapter" "$out/lib/${finalAttrs.pname}"
  '';

  meta = {
    description = "MCP adapter for Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-mcp-adapter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
