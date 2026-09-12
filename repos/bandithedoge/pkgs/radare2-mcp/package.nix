{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  meson,
  ninja,
  pkg-config,
  radare2,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "radare2-mcp";
  version = "1.8.8";
  src = fetchFromGitHub {
    owner = "radareorg";
    repo = "radare2-mcp";
    rev = finalAttrs.version;
    hash = "sha256-ttx+lklMiXxFmSVAVAgPPuI3iMTLQGDacyakY3aVF4Q=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    radare2
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "MCP stdio server for radare2";
    homepage = "https://github.com/radareorg/radare2-mcp";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "r2mcp";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
