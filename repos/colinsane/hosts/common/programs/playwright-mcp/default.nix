{ pkgs, ... }:
{
  sane.programs.playwright-mcp = {
    packageUnwrapped = pkgs.playwright-mcp.override {
      # playwright-mcp returns file links relative to cwd. when running sandboxed
      # or with --output-dir outside cwd, those relative links are useless.
      # patch the bundled coreBundle.js so file names are returned as absolute paths instead.
      # original file: <repo:Microsoft/playwright:packages/playwright-core/src/tools/backend/response.ts>
      playwright-test = pkgs.playwright-test.overrideAttrs (prevAttrs: {
        postInstall = (prevAttrs.postInstall or "") + ''
          substituteInPlace $out/lib/node_modules/playwright-core/lib/coreBundle.js \
            --replace-fail \
              '_computeRelativeTo(fileName) {' \
              '_computeRelativeTo(fileName) { return fileName;'
        '';
      });
    };

    sandbox.net = "clearnet";
    # to support `--output-dir $OUTPUT_DIR`
    sandbox.autodetectCliPaths = "existingDir";
  };
}
