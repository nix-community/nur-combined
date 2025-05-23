{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  wrapGAppsHook3,
  wxGTK32,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mapfab";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "pubby";
    repo = "mapfab";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OnXzHMseEz4dKemCyIPB7Dw73cWhihrmfjoYqkmcWEk=";
  };

  twod = fetchFromGitHub {
    owner = "pubby";
    repo = "2d";
    rev = "cd148969b02ced983e998eaa369ac81e5fdfd825";
    hash = "sha256-LrbbBP7BzTM4v2FFYLg2BNrk7I0mYr3zfRbbwSrTT4Q=";
  };

  patches = [
    # Unset GIT_COMMIT
    (fetchpatch2 {
      url = "https://github.com/FedericoSchonborn/mapfab/commit/6eeab0ae2bc4618d0091226417bc073aa5675daf.patch";
      hash = "sha256-NwLX5hCMBzakS3Abbwff+jOkYiMR+W2O7RUJoZbKbDY=";
    })
  ];

  nativeBuildInputs = [
    wrapGAppsHook3
    wxGTK32 # wx-config
  ];

  buildInputs = [
    wxGTK32
  ];

  strictDeps = true;

  makeFlags = [
    "release"
  ];

  preBuild = ''
    rmdir src/2d
    cp -r ${finalAttrs.twod} src/2d
  '';

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
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
