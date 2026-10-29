{
  lib,
  python3Packages,
  fetchFromGitHub,
  linuxPackages,
  nix-update-script,
  runCommand,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nvidia-linux-vbios-vix-loader";
  version = "0-unstable-2026-10-29";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Panchovix";
    repo = "nvidia-linux-vbios-vix-loader";
    rev = "c05415a69898c237bc60e2cdb3a8496a59fcad0e";
    hash = "sha256-ZHnMaTt90R7opDXAyCMFzL3MDKrgj/4icZVQJ5ZeSQM=";
  };

  build-system = [ python3Packages.setuptools ];

  nativeCheckInputs = [ python3Packages.pytestCheckHook ];
  enabledTestPaths = [ "tests" ];
  disabledTests = [
    # Expects the launcher next to a source checkout, not the installed package.
    "test_launcher_and_child_error_lines"
  ];

  pythonImportsCheck = [ "nvidia_vbios.driver" ];

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

    # The override module patches the driver's open sources with this command,
    # so check that the loader still recognises the current R615 branch.
    tests.driver-prepare = runCommand "nvidia-linux-vbios-vix-loader-driver-prepare" { } ''
      ${lib.getExe finalAttrs.finalPackage} driver prepare \
        --source ${linuxPackages.nvidiaPackages.new_feature.open.src} --destination patched > /dev/null
      grep -q _kgspVbiosOverridePrepare patched/src/nvidia/src/kernel/gpu/gsp/kernel_gsp.c
      touch $out
    '';
  };

  meta = {
    description = "Patches the NVIDIA open kernel modules to load a modified VBIOS per GPU in memory at boot";
    homepage = "https://github.com/Panchovix/nvidia-linux-vbios-vix-loader";
    license = with lib.licenses; [
      gpl3Plus
      mit
    ];
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "nvbios";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
