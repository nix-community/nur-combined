{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  gettext,
  desktop-file-utils,
  appstream,
  wrapGAppsHook4,
  glib,
  gtk4,
  libadwaita,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "savedesktop";
  version = "4.1";

  src = fetchFromGitHub {
    owner = "vikdevelop";
    repo = "SaveDesktop";
    tag = finalAttrs.version;
    hash = "sha256-t8nq4VmV1fC72uqNp+yYV5ekLKzf51CwmjWiq6tsZwM=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    desktop-file-utils
    appstream
    wrapGAppsHook4
    python3Packages.wrapPython
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    python3Packages.pygobject3
  ];

  pythonPath = [ python3Packages.pygobject3 ];

  postFixup = ''
    wrapProgram $out/bin/savedesktop \
      --prefix PYTHONPATH : "${python3Packages.pygobject3}/${python3Packages.python.sitePackages}"
  '';

  meta = {
    description = "Save and restore your Linux desktop configuration";
    homepage = "https://github.com/vikdevelop/SaveDesktop";
    changelog = "https://github.com/vikdevelop/SaveDesktop/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "savedesktop";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
