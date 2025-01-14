{
  lib,
  stdenv,
  fetchFromSourcehut,
  pkg-config,
  wayland-scanner,
  pixman,
  wayland,
# nix-update-script,
}:

stdenv.mkDerivation {
  pname = "wayneko";
  version = "0-unstable-2024-03-29";

  src = fetchFromSourcehut {
    owner = "~leon_plickat";
    repo = "wayneko";
    rev = "c1919dc3a7e610d30e4c06efaa5af85941f27d86";
    hash = "sha256-2cbEcDK6WZPe4HvY1pxmZVyDAj617VP1l0Gn7uSlNaE=";
  };

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    pixman
    wayland
  ];

  makeFlags = [ "PREFIX=${builtins.placeholder "out"}" ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error";

  # passthru.updateScript = nix-update-script {
  #   extraArgs = [
  #     "--version"
  #     "branch"
  #   ];
  # };

  meta = {
    mainProgram = "wayneko";
    description = "Display an animated neko cat on the bottom of an output";
    homepage = "https://sr.ht/~leon_plickat/wayneko/";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
