{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  boost,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nesfab";
  version = "1.6_mac";

  src = fetchFromGitHub {
    owner = "pubby";
    repo = "nesfab";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Mypn4N9+h/Wnxu47sI8jYVSDPiyQ7+aZoE3by2M9XQo=";
  };

  patches = [
    # Unset GIT_COMMIT
    (fetchpatch {
      url = "https://github.com/FedericoSchonborn/nesfab/commit/d755b1a646f7842e953cb6f34360992a7d7337b2.patch";
      hash = "sha256-KhLK1KXBkA1REu9qXDfHTzlAE9a9ILfzWhZGxAwEVak=";
    })
  ];

  buildInputs = [ boost ];

  makeFlags = [ "release" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp nesfab $out/bin/nesfab

    runHook postInstall
  '';

  strictDeps = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "nesfab";
    description = "Programming language that targets the Nintendo Entertainment System";
    homepage = "https://github.com/pubby/nesfab";
    changelog = "https://github.com/pubby/nesfab/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
