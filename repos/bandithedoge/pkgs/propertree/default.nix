{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.propertree) pname src;
  version = sources.propertree.date;

  buildInputs = with pkgs; [
    (pkgs.python3.withPackages (ps: with ps; [tkinter]))
    copyDesktopItems
    makeWrapper
  ];

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "propertree";
      exec = "propertree";
      desktopName = "ProperTree";
      categories = ["Utility"];
    })
  ];

  buildPhase = ''
    mkdir -p $out/libexec $out/bin
    cp -r $src $out/libexec/propertree
    patchShebangs
    makeWrapper $out/libexec/propertree/ProperTree.py $out/bin/propertree
  '';

  meta = with pkgs.lib; {
    description = "Cross platform GUI plist editor written in python.";
    homepage = "https://github.com/corpnewt/ProperTree";
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
