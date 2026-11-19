{
  bash,
  coreutils,
  fetchFromGitHub,
  git,
  lib,
  nix-update-script,
  perl,
  procps,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mcpls";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "bug-ops";
    repo = "mcpls";
    rev = "v${finalAttrs.version}";
    hash = "sha256-vq2uh4OTur7lJp83TegBqHblb2+nJjcx1DjBqTZHVRU=";
  };

  cargoHash = "sha256-9a7ww4rKXx5Jtw+wTc4jZJg8WYei5YNGUw0gBRtOBUA=";

  postPatch = ''
    substituteInPlace \
      crates/mcpls-cli/tests/cli_integration.rs \
      crates/mcpls-core/src/runtime/untrusted.rs \
      --replace-fail '/usr/bin/env' '${coreutils}/bin/env' \
      --replace-fail '/bin/sh' '${bash}/bin/sh' \
      --replace-fail '{}:/usr/bin:/bin' '{}:${
        lib.makeBinPath [
          bash
          coreutils
        ]
      }'
  '';

  nativeCheckInputs = [
    git
    perl
    procps
  ];

  dontUseCargoParallelTests = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Universal MCP to LSP bridge";
    longDescription = ''
      mcpls exposes Language Server Protocol capabilities as Model Context
      Protocol tools, enabling AI agents to access semantic code intelligence
      such as hover, go-to-definition, find-references, diagnostics, and
      workspace-wide symbol search.
    '';
    homepage = "https://github.com/bug-ops/mcpls";
    license = lib.licenses.mit;
    mainProgram = "mcpls";
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux;
  };
})
