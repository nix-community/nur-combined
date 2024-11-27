{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  testers,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cpuid2cpuflags";
  version = "14";

  src = fetchFromGitHub {
    owner = "projg2";
    repo = "cpuid2cpuflags";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-52pK6C7rmkfuWOsI6X0xksdfWLPCN3yOjSx0tG3IjFo=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

    updateScript = nix-update-script { };
  };

  meta = {
    mainProgram = "cpuid2cpuflags";
    description = "Tool to generate flags for your CPU";
    homepage = "https://github.com/projg2/cpuid2cpuflags";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
