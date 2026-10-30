{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bin-cpuflags-x86";
  version = "1.0.10";

  src = fetchFromGitHub {
    owner = "HanabishiRecca";
    repo = "bin-cpuflags-x86";
    tag = finalAttrs.version;
    hash = "sha256-Atq0vH6KB7jdetdG+ANiuJB8RE5LlEmgOOnt4Xx3WXk=";
  };
  __structuredAttrs = true;
  strictDeps = true;

  cargoHash = "sha256-dQ98aNa5f0LAM8ySoJaEpFbIfEgudYWXJ+XohmRc6As=";

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
