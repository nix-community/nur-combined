{
  # keep-sorted start
  buildNpmPackage,
  chromium,
  fetchFromGitHub,
  lib,
  # keep-sorted end
}:
buildNpmPackage {
  pname = "excalidash-mcp";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "davifernan";
    repo = "excalidash-mcp";
    rev = "f6aa533df9effd00696286bc972d09136f496509";
    hash = "sha256-5Le5MgLTQgVDuNqN18Se/4tZi2THz5GY8S9YYlR8Tso=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-FUzgG5v9XkhuGKLTpF85M6rMH8SIL/7V18TkxF+eU78=";
  npmBuildScript = "build";
  npmFlags = ["--legacy-peer-deps"];
  env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";

  # Use Nix Chromium without downloading a browser into the user profile.
  postPatch = ''
    substituteInPlace src/browser.js \
      --replace-fail 'chromiumSandbox:' 'executablePath: "${lib.getExe chromium}", chromiumSandbox:' \
      --replace-fail 'chromium.executablePath()' '"${lib.getExe chromium}"'
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    # Chromium is supplied by Nix, so a missing download cache is not an error.
    node --input-type=module -e 'import { assertBrowserInstalled } from "./src/browser.js"; await assertBrowserInstalled();'
    # The build sandbox cannot create Chromium namespaces; runtime keeps sandboxing enabled.
    EXCALIDASH_DISABLE_BROWSER_SANDBOX=1 node --test --experimental-test-isolation=none \
      --test-skip-pattern='startup names the browser setup command' test/*.test.js
    runHook postCheck
  '';

  meta = with lib; {
    # keep-sorted start
    description = "MCP server for live ExcaliDash drawing with Mermaid and automatic layout";
    homepage = "https://github.com/davifernan/excalidash-mcp";
    license = licenses.mit;
    mainProgram = "excalidash-mcp";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
