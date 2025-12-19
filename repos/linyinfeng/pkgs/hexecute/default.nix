{
  buildGoModule,
  go,
  fetchFromGitHub,
  lib,

  pkg-config,

  wayland,
  wayland-protocols,
  libxkbcommon,
  libGL,
  libGLU,
  mesa,
  xorg,

  nix-update-script,
}:

buildGoModule rec {
  pname = "hexecute";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "ThatOtherAndrew";
    repo = "Hexecute";
    rev = "v${version}";
    hash = "sha256-/I3om7qcgEic57+WS65TaXpwkpliVsQOxCK/fHkS4PQ=";
  };

  vendorHash = "sha256-CIlYhcX7F08Xwrr3/0tkgrfuP68UU0CeQ+HV63b6Ddg=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libxkbcommon
    libGL
    libGLU
    mesa
    xorg.libX11
  ];

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = pname; };
  };

  meta = {
    description = "Launch apps by casting spells! 🪄";
    homepage = "https://github.com/ThatOtherAndrew/Hexecute";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    broken = !(lib.versionAtLeast go.version "1.25.1");
  };
}
