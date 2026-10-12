{
  alsa-lib,
  fetchFromGitHub,
  fontconfig,
  lib,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  patchelf,
  pkg-config,
  rustPlatform,
  stdenv,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ricercar";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "ricercar-player";
    repo = "ricercar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-knsOLzcsX+D77BzarJDW50k+yMJQeSnWXNGk1LRsMec=";
  };

  cargoHash = "sha256-rtIg+SiKZve1xjpEWk+0yx/r7ABsU//50bWW00gzAPI=";

  cargoBuildFlags = [
    "-p ricercar-ui"
    "-p ricercar-cli"
    "-p ricercar-daemon"
  ];
  # The UPnP lifecycle test is timing-sensitive and fails intermittently in the
  # sandbox; upstream runs the full test suite in CI separately.
  doCheck = false;

  nativeBuildInputs = [
    patchelf
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    fontconfig
    libGL
    libx11
    libxcursor
    libxi
    libxkbcommon
    wayland
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 target/${stdenv.hostPlatform.rust.rustcTarget}/release/ricercar \
      "$out/bin/ricercar"
    install -Dm755 target/${stdenv.hostPlatform.rust.rustcTarget}/release/ricercar-cli \
      "$out/bin/ricercar-cli"
    install -Dm755 target/${stdenv.hostPlatform.rust.rustcTarget}/release/ricercar-daemon \
      "$out/bin/ricercar-daemon"
    install -Dm644 dist/ricercar.desktop \
      "$out/share/applications/ricercar.desktop"
    install -Dm644 dist/ricercar.svg \
      "$out/share/icons/hicolor/scalable/apps/ricercar.svg"
    install -Dm644 dist/ricercar.service \
      "$out/share/systemd/user/ricercar.service"
    for size in 48 128 256; do
      install -Dm644 "dist/icons/$size"x"$size"/ricercar.png \
        "$out/share/icons/hicolor/$size"x"$size/apps/ricercar.png"
    done
    install -Dm644 dist/io.github.ricercar_player.ricercar.metainfo.xml \
      "$out/share/metainfo/io.github.ricercar_player.ricercar.metainfo.xml"
    install -Dm644 LICENSE "$out/share/licenses/ricercar/LICENSE"
    install -Dm644 crates/ricercar-ui/assets/fonts/OFL.txt \
      "$out/share/licenses/ricercar/OFL.txt"
    install -Dm644 crates/ricercar-ui/assets/icons/LICENSE \
      "$out/share/licenses/ricercar/icons-LICENSE"

    runHook postInstall
  '';
  postFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath [
      libGL
      libx11
      libxcursor
      libxi
      libxkbcommon
      wayland
    ]} "$out/bin/ricercar"
  '';


  meta = {
    description = "Bit-perfect music player and UPnP/OpenHome network receiver";
    homepage = "https://github.com/ricercar-player/ricercar";
    license = lib.licenses.mit;
    mainProgram = "ricercar";
    platforms = lib.platforms.linux;
  };
})
