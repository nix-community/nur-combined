{
  lib,
  pkgs,
  sources,
  pythonPkgs ? pkgs.python3Packages,
}:
pythonPkgs.buildPythonPackage rec {
  inherit (sources.niriswitcher) pname version src;

  pyproject = true;

  build-system = with pythonPkgs; [
    hatchling
  ];

  nativeBuildInputs = with pkgs; [
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = with pkgs; [
    gtk4-layer-shell
    gtk4
    libadwaita
  ];

  propagatedBuildInputs = with pythonPkgs; [
    pygobject3
  ];

  ldDeps = with pkgs; [
    gtk4-layer-shell
  ];

  dontWrapGApps = true;

  makeWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath ldDeps}"
    "\${gappsWrapperArgs[@]}"
  ];

  meta = with lib; {
    description = "An application switcher for niri";
    homepage = "https://github.com/isaksamsten/niriswitcher";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "niriswitcher";
  };
}
