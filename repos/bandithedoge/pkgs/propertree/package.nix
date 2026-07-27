{
  sources,

  lib,
  stdenv,

  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  python3,
}:
stdenv.mkDerivation {
  inherit (sources.propertree) pname src;
  version = sources.propertree.date;

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

  meta = {
    description = "Cross platform GUI plist editor written in python.";
    homepage = "https://github.com/corpnewt/ProperTree";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    mainProgram = "propertree";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
