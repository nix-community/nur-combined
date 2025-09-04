{ lib
, stdenv
, fetchgit
, meson
, ninja
, pkg-config
, wayland
, wayland-protocols
, wayland-scanner
, libglvnd
, xorg
, libdrm
, libpulseaudio
, gitUpdater
}:

stdenv.mkDerivation rec {
  pname = "gpu-screen-recorder-ui";
  version = "1.7.3";

  src = fetchgit {
    url = "https://repo.dec05eba.com/${pname}";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-DDnUr1uRGgQxpawH3ykX1FFbshA7KY9aNSjjOFaUXDY=";
  };

  nativeBuildInputs = [ 
    meson 
    ninja 
    pkg-config
  ];
  buildInputs = [
    libglvnd
    xorg.libX11
    xorg.libXrandr
    xorg.libXrender
    xorg.libXcomposite
    xorg.libXfixes
    xorg.libXext
    xorg.libXi
    xorg.libXcursor
    libdrm
    wayland
    wayland-scanner
    libpulseaudio
  ];

  strictDeps = true;

  mesonFlags = [
    (lib.mesonBool "systemd" true)
    (lib.mesonBool "capabilities" false)
  ];

  passthru.updateScript = gitUpdater {
    url = "https://repo.dec05eba.com/${pname}";
    rev-prefix = "";
  };

  meta = with lib; {
    description = "A fullscreen overlay UI for GPU Screen Recorder in the style of ShadowPlay";
    homepage = "https://git.dec05eba.com/gpu-screen-recorder-ui/";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = [ ];
    mainProgram = "gsr-ui";
  };
}
