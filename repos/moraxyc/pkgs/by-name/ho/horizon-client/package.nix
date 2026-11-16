{
  lib,
  stdenv,
  rustPlatform,
  pkg-config,
  alsa-lib,
  udev,
  vulkan-loader,
  libglvnd,
  wayland,
  libxkbcommon,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  libxcb,
  horizon-prepare,
  sources,
  source ? sources.horizon,
}:
rustPlatform.buildRustPackage {
  pname = "horizon-client";
  inherit (source) version src;

  cargoLock = source.cargoLock;

  cargoBuildFlags = [
    "--package=horizon-game"
    "--bin=horizon-client"
    "--package=horizon-client-lib"
    "--bin=horizon-ctl"
  ];

  env = {
    HORIZON_VERSION = source.version;
    # horizon-mod-host's build script falls back to `git rev-parse HEAD`, but the source has no .git.
    HORIZON_GAME_BUILD_ID = source.rawVersion;
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    udev
  ];

  # The game's tests need prepared Minecraft resources, which cannot be redistributed.
  doCheck = false;

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --add-rpath ${
      lib.makeLibraryPath [
        vulkan-loader
        libglvnd
        wayland
        libxkbcommon
        libx11
        libxcursor
        libxi
        libxrandr
        libxcb
      ]
    } $out/bin/horizon-client
  '';

  passthru = { inherit horizon-prepare; };

  meta = {
    description = "Minecraft: Java Edition rebuilt in Rust";
    homepage = "https://github.com/horizon-rust/horizon";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "horizon-client";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
