{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bin-cpuflags-x86";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "HanabishiRecca";
    repo = "bin-cpuflags-x86";
    tag = finalAttrs.version;
    hash = "sha256-1+UHA6xWzO5ftaqZWVsfiXW75SBUQP2ukk1P1OYMVLk=";
  };

  cargoHash = "sha256-3il1w8Y2p3qt6WLyqSwIwt5ubh2QAM9Fdg14NS0UqkE=";

  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/HanabishiRecca/bin-cpuflags-x86/releases/tag/v${finalAttrs.version}";
    mainProgram = "bin-cpuflags-x86";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Small CLI tool to detect CPU flags (instruction sets) of X86 binaries";
    homepage = "https://github.com/HanabishiRecca/bin-cpuflags-x86";
    license = lib.licenses.mit;
  };
})
