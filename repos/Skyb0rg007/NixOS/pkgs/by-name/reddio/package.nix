{
  stdenv,
  fetchFromGitLab,
  lib,
  config,
  versionCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "reddio";
  version = "0.52";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitLab {
    owner = "aaronNG";
    repo = "reddio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Bhe3icWycQXwwyBp9z1GpnTYAfAp3m79orfMITTU2Z8=";
  };

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-V";
  doInstallCheck = true;

  dontBuild = true;

  makeFlags = [ "PREFIX=$(out)" ];

  passthru.updateScript = null; # upstream mostly dormant, last tag 2022

  meta = {
    description = "Command-line interface for Reddit";
    homepage = "https://gitlab.com/aaronNG/reddio/";
    changelog = "https://gitlab.com/aaronNG/reddio/-/releases/${finalAttrs.src.tag}";
    mainProgram = "reddio";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
