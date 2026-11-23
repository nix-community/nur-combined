{
  lib,
  rustPlatform,
  horizon,
}:

# The same release and lockfile as `horizon`, so the tool that writes Horizon's
# resources always matches the client that reads them: a version bump of
# `horizon` carries over here, and the pins cannot drift apart.
rustPlatform.buildRustPackage {
  pname = "horizon-prepare";
  version = horizon.version;

  src = horizon.src;

  cargoLock.lockFile = ../horizon/Cargo.lock;

  # Only the preparation tool; it needs the vanilla jars, never a GPU.
  cargoBuildFlags = [
    "--package=horizon-prepare"
    "--bin=horizon-prepare"
  ];
  cargoTestFlags = [ "--package=horizon-prepare" ];

  meta = {
    description = "Prepare Horizon's resources from the player's own Minecraft install";
    longDescription = ''
      horizon-prepare imports and checks the vanilla client and server jars that
      Minecraft 26.3 pins, runs vanilla's own exporters under Java 25, and writes
      the resource folder that `horizon-client --resources` reads. It downloads
      nothing: point `--minecraft-dir` at a game directory a launcher has already
      filled, and pass `--server-jar` the server jar of the same version. This
      package contains no Minecraft assets.
    '';
    homepage = "https://playhorizon.dev";
    license = lib.licenses.lgpl3Plus;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "horizon-prepare";
  };
}
