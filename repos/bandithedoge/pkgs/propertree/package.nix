{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  python3,
}:
stdenv.mkDerivation {
  pname = "propertree";
  version = "0-unstable-2026-06-20";
  src = fetchFromGitHub {
    owner = "corpnewt";
    repo = "ProperTree";
    rev = "51ed53dbe3c96a81686ae1fc47f6d2a92f668159";
    hash = "sha256-yDkIALfDh8LcCStZGPaUDQbmDdei6nir8XSed2ZqOIs=";
  };

  buildInputs = [
    (python3.withPackages (ps: with ps; [ tkinter ]))
    copyDesktopItems
    makeWrapper
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "propertree";
      exec = "propertree";
      desktopName = "ProperTree";
      categories = [ "Utility" ];
    })
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/libexec $out/bin
    cp -r $src $out/libexec/propertree
    patchShebangs
    makeWrapper $out/libexec/propertree/ProperTree.py $out/bin/propertree

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Cross platform GUI plist editor written in python.";
    homepage = "https://github.com/corpnewt/ProperTree";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    mainProgram = "propertree";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
