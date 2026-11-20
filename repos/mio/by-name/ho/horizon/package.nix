{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  nix-update-script,
  alsa-lib,
  udev,
  vulkan-loader,
  wayland,
  libxkbcommon,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  libxcb,
}:

let
  # wgpu and winit open these with dlopen, so the linker never records them.
  dlopened = [
    vulkan-loader
    wayland
    libxkbcommon
    libx11
    libxcursor
    libxi
    libxrandr
    libxcb
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "horizon";
  version = "0.2.97";

  src = fetchFromGitHub {
    owner = "horizon-rust";
    repo = "horizon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6oyG7R1Yfh4WvOBxKh1mHrMi9Kho5Ptic6nbDYPdb28=";
  };

  # The lockfile is the upstream one for this tag: every crate in it carries
  # its own checksum, and it has no git dependencies.
  cargoLock.lockFile = ./Cargo.lock;

  # The game itself; the server, the launcher and the tooling are separate
  # crates that this tag does not ship in the client workspace.
  cargoBuildFlags = [
    "--package=horizon-client"
    "--bin=horizon-client"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    udev
  ];

  # The tests read the prepared vanilla files in .local/, which a build never has.
  doCheck = false;

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --add-rpath ${lib.makeLibraryPath dlopened} $out/bin/horizon-client
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Minecraft: Java Edition rewritten from scratch in Rust";
    longDescription = ''
      Horizon is a from-scratch Rust implementation of Minecraft: Java Edition,
      checked against vanilla behaviour. This package builds the client with
      sound, controllers and Horizon's online extras; start it with
      `horizon-client --resources DIR`, where DIR is what upstream's
      horizon-prepare wrote. It contains no Minecraft assets.
    '';
    homepage = "https://playhorizon.dev";
    changelog = "https://github.com/horizon-rust/horizon/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl3Plus;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "horizon-client";
  };
})
