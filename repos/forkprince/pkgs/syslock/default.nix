{
  wayland-protocols,
  gtk4-layer-shell,
  wayland-scanner,
  fetchFromGitHub,
  wrapGAppsHook4,
  nlohmann_json,
  pkg-config,
  wlr-randr,
  libevdev,
  stdenv,
  gtkmm4,
  pam,
  lib,
  git,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "syslock";
  version = "unstable-2025-05-10";

  src = fetchFromGitHub {
    owner = "System64fumo";
    repo = "syslock";
    rev = "18910f055ec57619e1685c8dd57514513836402c";
    hash = "sha256-TaEkjxgw1yK5eaRs7mTxKsPt79ngID9F1L0Yqf/VFUM=";
  };

  nativeBuildInputs = [
    wayland-protocols
    wayland-scanner
    wrapGAppsHook4
    nlohmann_json
    pkg-config
    wlr-randr
    libevdev
    pam
    git
  ];

  buildInputs = [
    gtk4-layer-shell
    gtkmm4
  ];

  # The auto-monitor patch may not be needed, further testing is needed.
  patches = [./wayland-protocols.patch ./auto-monitor.patch];

  NIX_CFLAGS_COMPILE = "-fexceptions";

  makeFlags = ["WAYLAND_PROTOCOLS_DIR=${wayland-protocols}/share/wayland-protocols"];

  installPhase = ''
    runHook preInstall
    install -Dm755 build/syslock $out/bin/syslock
    install -Dm755 build/libsyslock.so $out/lib/libsyslock.so
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/syslock \
      --set LD_LIBRARY_PATH $out/lib
  '';

  meta = {
    homepage = "https://github.com/System64fumo/syslock";
    description = "Simple screen locker for wayland written in gtkmm 4.";
    mainProgram = "syslock";
    license = lib.licenses.wtfpl;
    maintainers = ["Prinky"];
    platforms = ["x86_64-linux"];
    sourceProvenance = with lib.sourceTypes; [fromSource];
  };
})
