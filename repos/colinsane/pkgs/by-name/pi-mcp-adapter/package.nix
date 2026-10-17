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
  version = "5.2.0";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-mcp-adapter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5rqEGUxi0jA7ExKh4i2KEQOHgZ3vJuZ0bf16NY23Res=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-XQYXNDSmEij+1QHHnOmx1ofDBTyXbao9xQ5e8zu0Oq8=";

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
