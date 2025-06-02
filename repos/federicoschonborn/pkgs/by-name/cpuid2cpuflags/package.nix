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
  version = "16";

  src = fetchFromGitHub {
    owner = "projg2";
    repo = "cpuid2cpuflags";
    tag = "v${finalAttrs.version}";
    hash = "sha256-r1ZvNzPcAnADyb7f6aFGljAGMXIvXQMcQau4ezfMdzs=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  strictDeps = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "cpuid2cpuflags";
    description = "Tool to generate flags for your CPU";
    homepage = "https://github.com/projg2/cpuid2cpuflags";
    changelog = "https://github.com/projg2/cpuid2cpuflags/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
