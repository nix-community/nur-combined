{
  lib,
  buildNpmPackage,
  playwright-driver,
  playwright-test,
  source,
}:
buildNpmPackage (finalAttrs: {
  pname = "playwright-cli";
  version = lib.removePrefix "v" source.version;

  inherit (source) src;

  npmDepsHash = "sha256-u44jWprmr3RdzB3aDL3K0ShT5lLxr175z3C8pN43YFA=";

  dontNpmBuild = true;

  # Resolve browsers from the Nix store and default to store chromium, since the
  # CLI otherwise falls back to the absent system "chrome" channel.
  # PLAYWRIGHT_MCP_BROWSER is shared config read by the CLI too; `--browser`
  # still overrides it.
  makeWrapperArgs = [
    "--set"
    "PLAYWRIGHT_BROWSERS_PATH"
    "${playwright-driver.browsers}"
    "--set-default"
    "PLAYWRIGHT_MCP_BROWSER"
    "chromium"
  ];

  # Use nixpkgs' playwright so it points at the store browsers wired up above.
  postInstall = ''
    pkg_dir="$out/lib/node_modules/@playwright/cli"
    rm -rf "$pkg_dir/node_modules/playwright"
    rm -rf "$pkg_dir/node_modules/playwright-core"
    ln -s ${playwright-test}/lib/node_modules/playwright "$pkg_dir/node_modules/playwright"
    ln -s ${playwright-test}/lib/node_modules/playwright-core "$pkg_dir/node_modules/playwright-core"
  '';

  meta = {
    changelog = "https://github.com/microsoft/playwright-cli/releases/tag/v${finalAttrs.version}";
    description = "CLI for common Playwright actions designed for coding agents";
    homepage = "https://github.com/microsoft/playwright-cli";
    license = lib.licenses.asl20;
    mainProgram = "playwright-cli";
  };
})
