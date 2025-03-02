{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  versionCheckHook,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cpuid2cpuflags";
  version = "15";

  src = fetchFromGitHub {
    owner = "projg2";
    repo = "cpuid2cpuflags";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-wLkb1TXqMZaB9bjh8T7m31DMXT0uY6/FjcDwFh/SjYY=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  nativeInstallCheckInputs = [ versionCheckHook ];

  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "cpuid2cpuflags";
    description = "Tool to generate flags for your CPU";
    homepage = "https://github.com/projg2/cpuid2cpuflags";
    changelog = "https://github.com/projg2/cpuid2cpuflags/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
