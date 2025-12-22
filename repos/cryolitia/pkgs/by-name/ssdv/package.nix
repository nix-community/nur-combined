{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
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

  patches = [
    (fetchpatch {
      name = "fix-build-on-nix.patch";
      url = "https://github.com/Cryolitia-Forks/ssdv/commit/9b4c6f09a812be0bbc698206df9a5d650a23f232.patch";
      hash = "sha256-Xql/OXjRwQOYLJUcg5Uy4OaJDLfwEIt0BMz8zoYaROo=";
    })
  ];

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
