{
  lib,
  python3Packages,
  fetchFromGitHub,
  bash,
  coreutils,
  gnugrep,
  linuxPackages,
  nix-update-script,
  runCommand,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nvidia-linux-vbios-vix-loader";
  version = "0-unstable-2026-11-05";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Panchovix";
    repo = "nvidia-linux-vbios-vix-loader";
    rev = "9094f26da94efc4122000abc78a07ed8c1e32b22";
    hash = "sha256-KgeRmYnwg8BUb4WBJBJRzE6MHfnTlrJ4UVHjoWu/SLQ=";
  };

  build-system = [ python3Packages.setuptools ];

  nativeCheckInputs = [
    bash
    coreutils
    gnugrep
    python3Packages.pytestCheckHook
  ];
  postPatch = ''
    # Upstream fixtures assume FHS paths and PATH utilities; adapt them for the
    # Nix sandbox without skipping coverage.
    substituteInPlace tests/test_distribution_patches.py \
      --replace-fail 'dir="/var/tmp"' 'dir=None' \
      --replace-fail '#!/bin/sh' '#!${bash}/bin/bash' \
      --replace-fail 'grep -q "echo five" conftest.sh' '${gnugrep}/bin/grep -q "echo five" conftest.sh' \
      --replace-fail 'sleep 30' '${coreutils}/bin/sleep 30'
  '';
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
