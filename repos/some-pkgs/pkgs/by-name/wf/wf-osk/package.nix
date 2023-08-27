{ lib
, stdenv
, fetchFromGitHub
, cmake
, gtk-layer-shell
, gtkmm3
, meson
, ninja
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "wf-osk";
  version = "unstable-2020-09-01";

  src = fetchFromGitHub {
    owner = "WayfireWM";
    repo = "wf-osk";
    rev = "d2e2e3228913ffa800ca31402820d2d90619279e";
    hash = "sha256-FpVnvkZbeubgwP2wGoocmw5u9E9MgK6WHEFkVEo1sUA=";
  };

  nativeBuildInputs = [
    cmake
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    gtkmm3
    gtk-layer-shell
  ];

  dontUseCmakeConfigure = true;

  meta = with lib; {
    description = "A very, very basic on-screen keyboard using gtkmm, virtual-keyboard-v1 and layer-shell protocols";
    homepage = "https://github.com/WayfireWM/wf-osk";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "wf-osk";
  };
}
