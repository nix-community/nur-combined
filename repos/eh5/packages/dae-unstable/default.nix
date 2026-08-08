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
  version = "2.0.0-unstable-2026-07-31";

  src = fetchFromGitHub {
    owner = "daeuniverse";
    repo = "dae";
    rev = "caa6f5e91776bc86d5b0edc940bb7d264359863c";
    hash = "sha256-A+62QTun9gsHL1fJAxbCqGRE8vJJMaI/XO8tPhe0Yw4=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-S2dNFvMeZqGhzu+sIBGeaET4bQXfeucao6XR4QSTpog=";

  proxyVendor = true;
  
  patches = [
    ./0001-fix-control-revert-dns.ipversion_prefer-to-the-previ.patch
    ./0002-chore-control-cleanup-unused-rfc8305-implementation.patch
  ];

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
