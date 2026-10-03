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
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-mcp-adapter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-F8t9/nbU9yyv4aeA9PPkL2u8ilJGG2ax6+0SIzUORL4=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-nA3rdzXgc6/rMd4GZ2lpI48hSr3008GCJI9Os7r5RWQ=";

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
