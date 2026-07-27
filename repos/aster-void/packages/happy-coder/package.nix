{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
  makeBinaryWrapper,
  which,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "happy-coder";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "slopus";
    repo = "happy-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Y7BxCr9QuMOQOudUO64W50Ud+J4+95mENlmWYiEbVAQ=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-3C7fcLPX5Rg9j6mQ0iQFk6JFCFcnunmzVCGGMvlyFYQ=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
    makeBinaryWrapper
  ];

  # Patch to also check PATH for claude (for nix-installed claude)
  postConfigure = ''
    cat >> scripts/claude_version_utils.cjs << 'PATCH'

    // Nix patch: check PATH for claude first
    const _origGetClaudeCliPath = module.exports.getClaudeCliPath;
    module.exports.getClaudeCliPath = function() {
      try {
        const { execSync } = require('child_process');
        const claudePath = execSync('which claude', { encoding: 'utf-8' }).trim();
        if (claudePath && require('fs').existsSync(claudePath)) {
          return claudePath;
        }
      } catch (e) {}
      return _origGetClaudeCliPath();
    };
    PATCH
  '';

  postInstall = ''
    wrapProgram $out/bin/happy --prefix PATH : ${lib.makeBinPath [nodejs which]}
    wrapProgram $out/bin/happy-mcp --prefix PATH : ${lib.makeBinPath [nodejs which]}
  '';

  meta = {
    description = "Code on the go controlling claude code from your mobile device";
    homepage = "https://github.com/slopus/happy-cli";
    license = lib.licenses.mit;
    maintainers = [];
    mainProgram = "happy";
  };
})
