{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.powertab) pname version src;

  nativeBuildInputs = with pkgs; [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = with pkgs; [
    alsa-lib
    boost
    doctest
    minizip
    nlohmann_json
    pugixml
    qt6.qtbase
    qt6.qttools
    rtmidi
  ];

  meta = with pkgs.lib; {
    description = "View and edit guitar tablature.";
    homepage = "https://powertab.github.io";
    license = licenses.gpl3;
  };
}
