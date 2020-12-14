{ fetchFromGitHub, lib,
  gcc, libpng, python3, python38Packages, boost, mesa, libGL, lemon, flex, qt5, ninja, cmake,
  makeDesktopItem
}:

let
  commit = "ee525bbdad34ae94879fd055821f92bcef74e83f";
  version = builtins.substring 0 7 commit;
  desktopItem = makeDesktopItem {
    name = "antimony";
    exec = "antimony";
    desktopName = "Antimony";
    categories = "Office;Engineering";
  };
in
qt5.mkDerivation rec {
  name = "antimony-${version}";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "mkeeter";
    repo = "antimony";
    rev = commit;
    sha256 = "0q4hxl9w71rba4p9zbz4fv4m9y988bwczs1pkasbhqs4kspfncqr";
  };
  buildInputs = [
    gcc libpng python3 python38Packages.boost boost mesa libGL lemon flex qt5.qtbase ninja cmake
  ];
  cmakeFlags = [ "-GNinja" ];
  postInstall = ''
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications/
  '';

  meta = {
    description = "A graph-based constructive solid geometry CAD tool.";
    longDescription = "Antimony is a computer-aided design (CAD) tool from a parallel universe in which CAD software evolved from Lisp machines rather than drafting tables";
    homepage = "http://www.mattkeeter.com/projects/antimony/3/";
    downloadPage = "https://github.com/mkeeter/antimony";
    license = lib.licenses.mit;
  };
}