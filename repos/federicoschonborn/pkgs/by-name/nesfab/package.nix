{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  boost,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nesfab";
  version = "1.6_mac";

  src = fetchFromGitHub {
    owner = "pubby";
    repo = "nesfab";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Mypn4N9+h/Wnxu47sI8jYVSDPiyQ7+aZoE3by2M9XQo=";
  };

  patches = [
    # Unset GIT_COMMIT
    (fetchpatch2 {
      url = "https://github.com/FedericoSchonborn/nesfab/commit/d755b1a646f7842e953cb6f34360992a7d7337b2.patch";
      hash = "sha256-KhLK1KXBkA1REu9qXDfHTzlAE9a9ILfzWhZGxAwEVak=";
    })
  ];

  buildInputs = [
    boost
  ];

  strictDeps = true;

  makeFlags = [ "release" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp nesfab $out/bin/nesfab

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "nesfab";
    description = "Programming language that targets the Nintendo Entertainment System";
    homepage = "https://github.com/pubby/nesfab";
    changelog = "https://github.com/pubby/nesfab/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
