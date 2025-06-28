{
  sources,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (sources.bin-cpuflags-x86) pname version src;

  cargoHash = "sha256-C074LRS7r+bbSHUNWxavHW3YzBkmRAqBwjE4X2JCZYw=";
  useFetchCargoVendor = true;

  meta = {
    changelog = "https://github.com/HanabishiRecca/bin-cpuflags-x86/releases/tag/v${finalAttrs.version}";
    mainProgram = "bin-cpuflags-x86";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Small CLI tool to detect CPU flags (instruction sets) of X86 binaries";
    homepage = "https://github.com/HanabishiRecca/bin-cpuflags-x86";
    license = lib.licenses.mit;
  };
})
