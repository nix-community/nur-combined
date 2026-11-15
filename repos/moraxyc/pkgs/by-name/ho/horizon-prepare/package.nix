{
  lib,
  stdenv,
  rustPlatform,
  coreutils,
  jdk25_headless,
  versionCheckHook,
  sources,
  source ? sources.horizon,
}:
rustPlatform.buildRustPackage {
  pname = "horizon-prepare";
  inherit (source) version src;

  cargoLock = source.cargoLock;

  cargoBuildFlags = [
    "--package=horizon-prepare"
    "--bin=horizon-prepare"
  ];
  cargoTestFlags = [ "--package=horizon-prepare" ];

  env.HORIZON_VERSION = source.version;

  postInstall = ''
    root=$out/share/horizon/prepare
    install -Dm444 research-lock.json -t $root
    install -Dm444 crates/horizon-prepare/src/exporters.rs -t $root/crates/horizon-prepare/src
    mkdir -p $root/mods/horizon/src/test
    cp -r mods/horizon/src/test/java $root/mods/horizon/src/test/

    mkdir -p $out/libexec
    mv $out/bin/horizon-prepare $out/libexec/horizon-prepare
    substitute nix/horizon-prepare.sh $out/bin/horizon-prepare \
      --subst-var out \
      --subst-var-by shell ${stdenv.shell} \
      --subst-var-by coreutils ${coreutils} \
      --subst-var-by java ${jdk25_headless}
    chmod +x $out/bin/horizon-prepare
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  versionCheckKeepEnvironment = "HORIZON_PREPARE_ROOT";
  preVersionCheck = ''
    export HORIZON_PREPARE_ROOT="$TMPDIR/prepare-check"
  '';

  passthru.java = jdk25_headless;

  meta = {
    description = "Prepare Horizon resources from your own copy of Minecraft: Java Edition";
    homepage = "https://github.com/horizon-rust/horizon";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "horizon-prepare";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
