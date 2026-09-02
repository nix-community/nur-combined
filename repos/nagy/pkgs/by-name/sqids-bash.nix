{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bats,
  versionCheckHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sqids-bash";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "sqids";
    repo = "sqids-bash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eZGY6gW6puYzz8b7UHib1QwHelcw5knre4EaVR9ObwM=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  buildPhase = ''
    runHook preBuild
    patchShebangs src/sqids
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 src/sqids "$out/bin/sqids"
    runHook postInstall
  '';

  doCheck = true;

  nativeCheckInputs = [ bats ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-v";

  checkPhase = ''
    runHook preCheck
    bats tests/
    runHook postCheck
  '';

  meta = {
    description = "Generate unique IDs from numbers for bash (Sqids)";
    homepage = "https://github.com/sqids/sqids-bash";
    license = lib.licenses.mit;
    mainProgram = "sqids";
    maintainers = with lib.maintainers; [ nagy ];
  };
})
