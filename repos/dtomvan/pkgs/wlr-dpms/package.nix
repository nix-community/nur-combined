{
  lib,
  stdenv,
  fetchFromSourcehut,

  pkg-config,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation {
  pname = "wlr-dpms";
  version = "0-unstable-2025-11-28";

  src = fetchFromSourcehut {
    owner = "~dsemy";
    repo = "wlr-dpms";
    rev = "92dcde33b20d72fb23b3117a00a9f0a35fe6a37c";
    hash = "sha256-yjOv53+eM3/44pNBeG5VMEy6FY6A/9+i+sAbGuIDjEQ=";
  };

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
  ];
  buildInputs = [ wayland ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "change output power modes in wlroots compositors";
    homepage = "https://git.sr.ht/~dsemy/wlr-dpms";
    mainProgram = "wlr-dpms";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    platforms = lib.platforms.linux;
  };
}
