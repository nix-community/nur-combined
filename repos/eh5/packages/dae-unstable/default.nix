{
  lib,
  clang,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
  nixosTests,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "dae";
  version = "2.1.1-unstable-2026-09-20";

  src = fetchFromGitHub {
    owner = "daeuniverse";
    repo = "dae";
    rev = "17cc1de85dd0ae82f69cf0c182d99a1c35b193eb";
    hash = "sha256-TZ+47ldnYmxjEW+WYBpQMf+4ajbpJnBw/W9d1c7bYS0=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-N2noQXRV9Vewie4PiWkjDeX6U2+kF1kQ9L10kZ5X/LI=";

  proxyVendor = true;

  nativeBuildInputs = [ clang ];

  hardeningDisable = [
    "zerocallusedregs"
  ];

  buildPhase = ''
    runHook preBuild

    make CFLAGS="-D__REMOVE_BPF_PRINTK -fno-stack-protector -Wno-unused-command-line-argument" \
    NOSTRIP=y \
    VERSION=${finalAttrs.version} \
    OUTPUT=$out/bin/dae

    runHook postBuild
  '';

  # network required
  doCheck = false;

  postInstall = ''
    install -Dm444 install/dae.service $out/lib/systemd/system/dae.service
    substituteInPlace $out/lib/systemd/system/dae.service \
      --replace-fail "/usr/bin/dae" "$out/bin/dae"
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    tests = {
      inherit (nixosTests) dae;
    };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Linux high-performance transparent proxy solution based on eBPF";
    homepage = "https://github.com/daeuniverse/dae";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "dae";
  };
})
