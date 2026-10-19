{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
  update-guard,
  updater-tools,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-mcp-adapter";
  version = "5.3.2";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-mcp-adapter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-syx9/d3IGyTExenHwwaVFuFN5jZvM8gVn8/+W8bJ8jk=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-t+B+L93L2vpr4UNlqPKRRzNoiWA+Tv9wqXdIKsWCrFs=";

  dontNpmBuild = true;  # package.json defines no build script

  postPatch = ''
    # needs to be executable to have its shebang patched
    chmod +x cli.js
  '';

  passthru.updateScript = updater-tools.requireAll [
    (update-guard.days 3)
    (nix-update-script {})
  ];

  meta = {
    description = "MCP (Model Context Protocol) adapter extension for the Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-mcp-adapter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
