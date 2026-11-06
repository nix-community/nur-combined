{
  fetchFromGitHub,
  lib,
  rustPlatform,
  stdenv,
  testers,
  nix-update-script,
}:
let
  # The tutorial programs from example-hello. Its other binaries are
  # harnesses that need real Android libbinder on a device or emulator.
  exampleBins = [
    "authz_client"
    "authz_service"
    "gateway_service"
    "hello_async_client"
    "hello_async_service"
    "hello_callback_demo"
    "hello_client"
    "hello_service"
    "rpc_hello_client"
    "rpc_hello_service"
    "serde_demo"
    "shm_client"
    "shm_service"
    "unified_client"
    "unified_service"
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rsbinder-tools";
  version = "0.12.0";
  __structuredAttrs = true;

  outputs = [
    "out"
    "examples"
  ];

  src = fetchFromGitHub {
    owner = "hiking90";
    repo = "rsbinder";
    tag = "v${finalAttrs.version}";
    hash = "sha256-x7XZzzCzNb15bl7Yy2ts8bcNPzASWHvm9KZfR7/CIb8=";
  };

  cargoHash = "sha256-LuhXN+h+ZhlWTbUTSbjCY+a4VC2TADF/xsmd8pPEn34=";

  cargoBuildFlags = [
    "--package=rsbinder-tools"
  ];

  # Built separately so that example-hello's rsbinder features (rpc,
  # android_10_plus) are not unified into the rsbinder-tools binaries.
  postBuild = ''
    cargo build \
      -j "$NIX_BUILD_CORES" \
      --target ${stdenv.hostPlatform.rust.rustcTargetSpec} \
      --offline \
      --profile "$cargoBuildType" \
      --package=example-hello \
      --features=rpc \
      ${lib.concatMapStringsSep " " (bin: "--bin=${bin}") exampleBins}
  '';

  checkFlags = [
    # These tests require a mounted binderfs
    "--skip=test_client::"
    "--skip=test_sm::"
    "--skip=process_state::"
    "--skip=binderfs::tests::test_add_device"
    "--skip=tests::process_state"
    "--skip=thread_state::tests::"
  ];

  postInstall = ''
    mkdir -p "$examples/bin"
    mv -t "$examples/bin" ${lib.concatMapStringsSep " " (bin: "\"$out/bin/${bin}\"") exampleBins}
  '';

  passthru.updateScript = nix-update-script { };
  passthru.tests.rsb_hub-version = testers.testVersion {
    package = finalAttrs.finalPackage;
    command = "rsb_hub --version";
  };
  passthru.tests.rsb_device-version = testers.testVersion {
    package = finalAttrs.finalPackage;
    command = "rsb_device --version";
  };
  passthru.tests.rsb_service-version = testers.testVersion {
    package = finalAttrs.finalPackage;
    command = "rsb_service --version";
  };

  meta = {
    description = "CLI tools for Binder IPC on Linux";
    longDescription = ''
      rsbinder-tools provides two tools:

      rsb_device is a utility for initializing the Linux binder
      environment and creating binder device files.

      rsb_hub is a comprehensive service manager for Linux that replaces
      Android's service_manager functionality.
    '';
    homepage = "https://github.com/hiking90/rsbinder";
    changelog = "https://github.com/hiking90/rsbinder/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
