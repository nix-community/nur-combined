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
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-mcp-adapter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xVkIN2zmEnJyJUxxd50ymvf116ctvuu1c6NarH+ciEQ=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-sie79O/9s9FfM2OMlhbuY9NPdPcmF90OgiaOIPjysVU=";

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
