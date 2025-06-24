{
  lib,
  stdenv,
  fetchFromGitHub,
  logger,
  nix-update-script,
  testers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "socket-vmnet";
  version = "1.2.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "lima-vm";
    repo = "socket_vmnet";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MbmfCS8gG7XVbG7mVXGen7F/chEIyTvWSoHfwIiF+2s=";
  };

  nativeBuildInputs = [
    logger
  ];

  buildPhase = ''
    runHook preBuild
    make all SOURCE_DATE_EPOCH=0 VERSION=$version PREFIX=$out
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make install.bin install.doc SOURCE_DATE_EPOCH=0 VERSION=$version PREFIX=$out
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };
  };

  meta = {
    description = "Daemon to provide vmnet.framework support for rootless QEMU";
    homepage = "https://github.com/lima-vm/socket_vmnet";
    license = lib.licenses.asl20;
    platforms = lib.platforms.darwin;
    mainProgram = "socket_vmnet";
  };
})
