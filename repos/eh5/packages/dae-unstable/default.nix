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
  version = "unstable-2026-02-20";

  src = fetchFromGitHub {
    owner = "daeuniverse";
    repo = "dae";
    rev = "030902f519f5b63f839327fd2fa9d8f906f4c504";
    hash = "sha256-wIka/hzF2MzLebrgUHOB+BaRIEx4cD3TXPV9uqP9m7U=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-MJVmAg+xyS53295FZ5HYB4rfbWHjUFBkxIOBxqxQP3U=";

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
