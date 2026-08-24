{
  fetchgit,
  nix-update-script,
  stdenv,
  lib,
  makeWrapper,
  # Runtime dependnecies
  curl,
  inetutils,
  which,
}:
let
  additionalPath = lib.makeBinPath [
    curl
    inetutils
    which
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dn42-pingfinder";
  version = "0-unstable-2022-11-06";
  src = fetchgit {
    url = "https://git.lantian.pub/backup/dn42-pingfinder.git";
    rev = "8fd1af682dd6fab6bee6a72f44b8157661b7b65b";
    fetchSubmodules = false;
    hash = "sha256-eDTiY1OSR1+5DUaieaepxMVFe1qBVSyKhSMWtXavKUI=";
  };
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 clients/generic-linux-debian-redhat-busybox.sh $out/bin/dn42-pingfinder
    wrapProgram $out/bin/dn42-pingfinder \
      --suffix PATH : "${additionalPath}"

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
    description = "DN42 Pingfinder";
    homepage = "https://git.dn42.dev/dn42/pingfinder/src/branch/master/clients";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "dn42-pingfinder";
  };
})
