{
  lib,
  stdenv,
  rustPlatform,
  coreutils,
  jdk25_headless,
  versionCheckHook,
  sources,
  source ? sources.sunrise,
}:
rustPlatform.buildRustPackage {
  pname = "sunrise-prepare";
  inherit (source) version src;

  cargoLock = source.cargoLock;

  cargoBuildFlags = [
    "--package=sunrise-prepare"
    "--bin=sunrise-prepare"
  ];
  cargoTestFlags = [ "--package=sunrise-prepare" ];

  env.SUNRISE_VERSION = source.version;

  postInstall = ''
    root=$out/share/sunrise/prepare
    install -Dm444 research-lock.json -t $root
    install -Dm444 crates/sunrise-prepare/src/exporters.rs -t $root/crates/sunrise-prepare/src
    mkdir -p $root/mods/sunrise/src/test
    cp -r mods/sunrise/src/test/java $root/mods/sunrise/src/test/

    mkdir -p $out/libexec
    mv $out/bin/sunrise-prepare $out/libexec/sunrise-prepare
    substitute nix/sunrise-prepare.sh $out/bin/sunrise-prepare \
      --subst-var out \
      --subst-var-by shell ${stdenv.shell} \
      --subst-var-by coreutils ${coreutils} \
      --subst-var-by java ${jdk25_headless}
    chmod +x $out/bin/sunrise-prepare
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  versionCheckKeepEnvironment = "SUNRISE_PREPARE_ROOT";
  preVersionCheck = ''
    export SUNRISE_PREPARE_ROOT="$TMPDIR/prepare-check"
  '';

  passthru.java = jdk25_headless;

  meta = {
    description = "Prepare Sunrise's game files from your own copy of Minecraft: Java Edition 26.3";
    homepage = "https://playsunrise.net";
    license = {
      fullName = "PolyForm Shield License 1.0.0";
      spdxId = "PolyForm-Shield-1.0.0";
      url = "https://polyformproject.org/licenses/shield/1.0.0/";
      free = false;
      redistributable = true;
    };
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "sunrise-prepare";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
