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
  version = "1.5";

  src = fetchFromGitHub {
    owner = "pubby";
    repo = "nesfab";
    rev = "v${finalAttrs.version}";
    hash = "sha256-j0Xt06dzuSQYune/Yf8YqFL7g4yFlPHngBgcsQUjK08=";
  };

  patches = [
    # Unset GIT_COMMIT
    (fetchpatch {
      url = "https://github.com/FedericoSchonborn/nesfab/commit/cfe10d4f23303f0533800076cb32aa76e4bc3941.patch";
      hash = "sha256-o+IKti3G8YypT+DGveKJ2B/QZM8rt7Kx9Z20ltu4+9Q=";
    })
  ];

  buildInputs = [
    boost
  ];

  makeFlags = [
    "release"
  ];

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
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
