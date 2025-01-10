{ lib, stdenv, fetchFromGitLab, kame-tools, rstmcpp, qt6, portaudio, vgmstream }:

stdenv.mkDerivation rec {
  pname = "kame-editor";
  version = "1.4.1-unstable-2024-11-01";

  src = fetchFromGitLab {
    owner = "beelzy";
    repo = pname;
    rev = "1877a832c8c23683a26b3bbd5c7beec8de990714";
    hash = "sha256-VOqxGuFVFwrf8T6QSXSZV6ZYBh8Bcx8Weit7WBqvclA=";
  };

  postPatch = ''
    substituteInPlace kame-editor.pro \
      --replace-fail "/usr/local/bin/" "$out/bin/"
  '';

  qtWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ kame-tools vgmstream rstmcpp ]}"
    # even adding qt6.qtwayland doesn't make wayland work for some reason i'm not sure of yet
    "--set WAYLAND_DISPLAY \"\""
  ];

  buildInputs = [ qt6.qtbase portaudio ];
  nativeBuildInputs = [ qt6.qmake qt6.wrapQtAppsHook ];

  meta = with lib; {
    description = "GUI frontend for kame-tools; makes custom 3DS themes.";
    homepage = "https://beelzy.gitlab.io/kame-editor/";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
    mainProgram = "kame-editor";
  };
}
