{
  lib,
  stdenv,
  fetchFromCodeberg,
  fetchpatch,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ssdv";
  version = "0-unstable-2025-12-31";

  src = fetchFromCodeberg {
    owner = "fsphil";
    repo = "ssdv";
    rev = "d1ceda81b69f88741396f3e052b50c8ae40efb76";
    hash = "sha256-xhQBXN0V+BFKkeRjafy1RKFd7QLHE44zTkpRGo7wVtQ=";
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
    homepage = "https://codeberg.org/fsphil/ssdv";
    license = lib.licenses.gpl3Only;
    platforms = with lib.platforms; (linux ++ darwin);
    maintainers = with lib.maintainers; [ Cryolitia ];
    mainProgram = "ssdv";
  };
})
