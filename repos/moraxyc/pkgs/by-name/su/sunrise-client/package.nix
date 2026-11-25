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
  sunrise-prepare,
  sources,
  source ? sources.sunrise,
}:
rustPlatform.buildRustPackage {
  pname = "sunrise-client";
  inherit (source) version src;

  cargoLock = source.cargoLock;

  cargoBuildFlags = [
    "--package=sunrise-game"
    "--bin=sunrise-client"
    "--package=sunrise-client-lib"
    "--bin=sunrise-ctl"
  ];

  env = {
    SUNRISE_VERSION = source.version;
    # sunrise-mod-host's build script falls back to `local` when SUNRISE_GAME_BUILD_ID is unset.
    SUNRISE_GAME_BUILD_ID = source.rawVersion;
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
    } $out/bin/sunrise-client
  '';

  passthru = { inherit sunrise-prepare; };

  meta = {
    description = "Sunrise, Minecraft: Java Edition 26.3 rewritten in Rust, and sunrise-ctl";
    homepage = "https://playsunrise.net";
    license = {
      fullName = "PolyForm Shield License 1.0.0";
      spdxId = "PolyForm-Shield-1.0.0";
      url = "https://polyformproject.org/licenses/shield/1.0.0/";
      free = false;
      redistributable = true;
    };
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "sunrise-client";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
