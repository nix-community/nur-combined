{
  lib,
  rustPlatform,
  craneLib ? null,
  source,
  rustfmt,
}: let
  inherit (source) pname src;
  version = "0-unstable-${source.date}";

  postInstall = ''
    install -Dm644 LICENSE README.md -t $out/share/doc/pumpkin
  '';

  installCheckPhase = ''
    runHook preInstallCheck

    test -x $out/bin/pumpkin
    test -f $out/share/doc/pumpkin/LICENSE
    test -f $out/share/doc/pumpkin/README.md

    runHook postInstallCheck
  '';

  meta = {
    description = "Empowering everyone to host fast and efficient Minecraft servers";
    homepage = "https://github.com/Pumpkin-MC/Pumpkin";
    license = lib.licenses.gpl3Only;
    mainProgram = "pumpkin";
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
in
  if craneLib == null
  then
    # Fallback for consumers without crane (e.g. importing this repository's
    # default.nix with plain nixpkgs): a regular single-layer build.
    rustPlatform.buildRustPackage {
      inherit pname src version postInstall installCheckPhase meta;

      cargoHash = "sha256-wBOXR1oNQsNI0k+nBZhHciFt+PgTr9BktrmkWq4+MlU=";

      nativeBuildInputs = [rustfmt];

      cargoBuildFlags = ["--workspace"];

      doCheck = true;
      cargoTestFlags = ["--workspace"];

      doInstallCheck = true;
    }
  else let
    commonArgs = {
      inherit pname src;
      nativeBuildInputs = [rustfmt];
      cargoExtraArgs = "--workspace";
    };
    # Dependencies only. The version is deliberately constant so this layer
    # is rebuilt only when Cargo.lock or the toolchain changes, never on an
    # upstream version bump.
    cargoArtifacts = craneLib.buildDepsOnly (commonArgs
      // {
        version = "0";
        doCheck = false;
      });
  in
    craneLib.buildPackage (commonArgs
      // {
        inherit version cargoArtifacts postInstall installCheckPhase meta;
        doCheck = true;
        doInstallCheck = true;
      })
