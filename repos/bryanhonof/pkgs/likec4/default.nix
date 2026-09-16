{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  makeWrapper,
  playwright-driver,
  versionCheckHook,
}:

buildNpmPackage (finalAttrs: {
  pname = "likec4";
  version = "1.59.3";

  # The npm tarball ships the built CLI and web app; the git tree would need the
  # whole pnpm/turbo monorepo.
  src = fetchurl {
    url = "https://registry.npmjs.org/likec4/-/likec4-${finalAttrs.version}.tgz";
    hash = "sha256-/5E84ocmejQ1dY68MuWuoQV4dGJA/MHTT6NnhpwXWi4=";
  };

  # devDependencies point at unpublished workspace packages; playwright is taken
  # from nixpkgs instead, so its browser revisions match playwright-driver.
  postPatch = ''
    ${lib.getExe jq} \
      'del(.devDependencies) | del(.dependencies.playwright)' \
      package.json > package.json.new
    mv package.json.new package.json
    cp ${./package-lock.json} package-lock.json

    # vite derives its cache dir from the app root, which here is read-only.
    # The bundle holds null bytes, so substituteInPlace refuses it.
    sed -i 's|root:i,languageServices:e,clearScreen:!1,base:s,|&cacheDir:e.workspace+`/node_modules/.vite`,|' \
      dist/cli/index.mjs
    grep -q 'cacheDir:e.workspace' dist/cli/index.mjs
  '';

  npmDepsHash = "sha256-JPI5KPNvOowwTxsQXQNq2K0iN+ZG4MWobxMuoThj9Ws=";

  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    # playwright-driver is the playwright-core package, whose public API is all
    # the CLI imports from `playwright`.
    ln -s ${playwright-driver} $out/lib/node_modules/likec4/node_modules/playwright

    wrapProgram $out/bin/likec4 \
      --set-default PLAYWRIGHT_BROWSERS_PATH ${
        playwright-driver.selectBrowsers {
          withFirefox = false;
          withWebkit = false;
          withFfmpeg = false;
        }
      }
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Toolchain for architecture diagrams as code";
    homepage = "https://likec4.dev";
    changelog = "https://github.com/likec4/likec4/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bryanhonof ];
    platforms = lib.platforms.linux;
    mainProgram = "likec4";
  };
})
