{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  fuse,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nullfs";
  version = "0-unstable-2016-01-27";
  src = fetchFromGitHub {
    owner = "xrgtn";
    repo = "nullfs";
    rev = "0884f87ec01faaee219f59742c14ed3c3945f5c0";
    hash = "sha256-cokSWBZIeCfdxd+o59BssQetffFSdHrVipQuRLbqNdU=";
  };
  patches = [ ./6-nulnfs-fix-warnings.patch ];

  buildInputs = [ fuse ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 nul1fs nullfs nulnfs $out/bin/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "FUSE nullfs drivers";
    homepage = "https://github.com/xrgtn/nullfs";
    license = with lib.licenses; [ gpl1Only ];
    mainProgram = "nullfs";
  };
})
