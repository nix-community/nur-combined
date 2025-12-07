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
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "saatvik333";
    repo = "wayland-bongocat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hsCNbweWBqCQRCKnVTSQwwQCPz/U2KoqpZZE92Q5BhA=";
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

    install -Dm755 build/bongocat $out/bin/${finalAttrs.meta.mainProgram}
    install -Dm755 scripts/find_input_devices.sh $out/bin/bongocat-find-devices

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
