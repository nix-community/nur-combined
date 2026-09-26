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
  version = "2.38.0";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-mcp-adapter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NHyfYDtaypPpyebspSzq2OrG6FKiD1WeUlWMNc2kIsg=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-QwhvuhF6hZ3J50Tdam9PREmTLG4zUHLR9mR+JsZk3vs=";

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
