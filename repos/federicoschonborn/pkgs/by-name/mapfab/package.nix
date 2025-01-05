{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  wxGTK32,
  nix-update-script,
}:

let
  twod = fetchFromGitHub {
    owner = "pubby";
    repo = "2d";
    rev = "cd148969b02ced983e998eaa369ac81e5fdfd825";
    hash = "sha256-LrbbBP7BzTM4v2FFYLg2BNrk7I0mYr3zfRbbwSrTT4Q=";
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "mapfab";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "pubby";
    repo = "mapfab";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-OnXzHMseEz4dKemCyIPB7Dw73cWhihrmfjoYqkmcWEk=";
  };

  patches = [
    # Unset GIT_COMMIT
    (fetchpatch {
      url = "https://github.com/FedericoSchonborn/mapfab/commit/6eeab0ae2bc4618d0091226417bc073aa5675daf.patch";
      hash = "sha256-NwLX5hCMBzakS3Abbwff+jOkYiMR+W2O7RUJoZbKbDY=";
    })
  ];

  buildInputs = [
    wxGTK32
  ];

  preBuild = ''
    rmdir src/2d
    cp -r ${twod} src/2d
  '';

  makeFlags = [
    "release"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp mapfab $out/bin/mapfab

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "mapfab";
    description = "Level editor for creating (new) NES games";
    homepage = "https://github.com/pubby/mapfab";
    changelog = "https://github.com/pubby/mapfab/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
