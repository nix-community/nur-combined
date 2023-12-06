{ lib
, meson
, ninja
, pkg-config
, fetchFromGitHub
, python3Packages
, wrapGAppsHook4
, gtk4
, glib
, desktop-file-utils
, libadwaita
, fava
, appstream-glib
, shared-mime-info
, blueprint-compiler
, git
, webkitgtk_6_0
}:

python3Packages.buildPythonApplication rec {
  pname = "favagtk";
  version = "0.2.9";
  format = "other";

  src = fetchFromGitHub {
    owner = "johannesjh";
    repo = "favagtk";
    rev = "f51bc07d2ce050f574efcd4f499e4cdefbd90535";
    hash = "sha256-/gWMqitT+ecbmbCWbNoKBSmIMyb6y6TTUegjlsqGLJ4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils
    shared-mime-info
    blueprint-compiler
    git
  ];

  buildInputs = [
    gtk4
    glib
    libadwaita
    webkitgtk_6_0
  ];

  propagatedBuildInputs = with python3Packages; [ pygobject3 ] ++ [ fava ];

  # Prevent double wrapping, let the Python wrapper use the args in preFixup.
  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Desktop application for Fava and Beancount built using Python and GTK.";
    homepage = "https://github.com/johannesjh/favagtk";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ pokon548 ];
    mainProgram = "favagtk";
  };
}
