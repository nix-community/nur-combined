{
  fetchFromGitHub,
  lib,
  unstableGitUpdater,
  stdenv,
  libftdi1,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xvcd";
  version = "0-unstable-2025-03-06";
  src = fetchFromGitHub {
    owner = "tmbinc";
    repo = "xvcd";
    rev = "e24745d5fe29b52d30e5c08cda4f2ecdf4909abb";
    hash = "sha256-/O1Oal3RBqCNTgTzvFkq6DkUJH8rHWQyuoCu3e97tro=";
  };

  buildInputs = [ libftdi1 ];

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/xvcd $out/bin/xvcd

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/tmbinc/xvcd";
    hardcodeZeroVersion = true;
  };

  meta = {
    mainProgram = "xvcd";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Xilinx Virtual Cable Daemon";
    homepage = "https://github.com/tmbinc/xvcd";
    license = lib.licenses.cc0;
  };
})
