{
  lib,
  stdenv,
  pkg-config,
  fetchFromGitHub,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "wayland-bongocat";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "saatvik333";
    repo = "wayland-bongocat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qCLD/HoQB1fef5tjsYxZMZStfOvCRfV5jtfS02RIYf4=";
  };

  # Build toolchain and dependencies
  strictDeps = true;
  nativeBuildInputs = [
    pkg-config
    wayland-scanner
  ];
  buildInputs = [
    wayland
    wayland-protocols
    wayland-scanner
  ];

  preBuild = ''
    export WAYLAND_PROTOCOLS_DIR="${wayland-protocols}/share/wayland-protocols"
  '';

  makeFlags = [ "release" ];
  installPhase = ''
    runHook preInstall

    install -Dm755 build/release/bongocat $out/bin/${finalAttrs.meta.mainProgram}
    install -Dm644 man/bongocat.1 $out/share/man/man1/bongocat.1
    install -Dm644 bongocat.conf.example $out/share/bongocat/bongocat.conf.example

    runHook postInstall
  '';

  meta = {
    description = "Delightful Wayland overlay that displays an animated bongo cat reacting to your keyboard input!";
    homepage = "https://github.com/saatvik333/wayland-bongocat";
    mainProgram = "bongocat";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
