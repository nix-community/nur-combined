{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ssdv";
  version = "0-unstable-20250812";

  src = fetchFromGitHub {
    owner = "fsphil";
    repo = "ssdv";
    rev = "f19b60fc9a42e3d254ae51439bf8ff6f7abd6145";
    hash = "sha256-8CTVgBPysuxHIF6y2AY9wWYEi8BKs0pdLrucQvYJt+4=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m 755 ssdv $out/bin

    runHook postInstall
  '';

  meta = {
    description = "A robust version of the JPEG image format, for transmission over an unreliable medium";
    homepage = "https://github.com/fsphil/ssdv";
    license = lib.licenses.gpl3Only;
    platforms = with lib.platforms; (linux ++ darwin);
    maintainers = with lib.maintainers; [ Cryolitia ];
    mainProgram = "ssdv";
  };
})
