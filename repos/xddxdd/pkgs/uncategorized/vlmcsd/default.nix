{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vlmcsd";
  version = "svn1113-unstable-2023-07-28";
  src = fetchFromGitHub {
    owner = "Wind4";
    repo = "vlmcsd";
    rev = "70e03572b254688b8c3557f898e7ebd765d29ae1";
    hash = "sha256-BEi47U0rdkO+AlQRpntsaTgm5A4CSwS6LuffAl2kIaw=";
  };
  installPhase = ''
    runHook preInstall

    install -Dm755 bin/vlmcs $out/bin/vlmcs
    install -Dm755 bin/vlmcsd $out/bin/vlmcsd

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    mainProgram = "vlmcsd";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "KMS Emulator in C";
    homepage = "https://github.com/Wind4/vlmcsd";
    license = lib.licenses.mit;
  };
})
