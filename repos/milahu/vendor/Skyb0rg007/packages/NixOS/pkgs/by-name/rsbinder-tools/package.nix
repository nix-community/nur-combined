{
  fetchFromGitHub,
  lib,
  rustPlatform,
  testers,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rsbinder-tools";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "hiking90";
    repo = "rsbinder";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/e6VxcszH3golCy4smgPrxLJNwSykXh2LPlNX9G1ZA4=";
  };

  cargoHash = "sha256-0WRODytZdzEX6zx4tiICnlPck9V8p1FLtzx5g2ZhCw0=";

  cargoBuildFlags = [ "--package=rsbinder-tools" ];

  checkFlags = [
    # These tests require a mounted binderfs
    "--skip=test_client::"
    "--skip=test_sm::"
    "--skip=process_state::"
    "--skip=binderfs::tests::test_add_device"
    "--skip=tests::process_state"
    "--skip=thread_state::tests::"
  ];

  passthru.tests.rsb_hub-version = testers.testVersion {
    package = finalAttrs.finalPackage;
    command = "rsb_hub --version";
  };
  passthru.tests.rsb_device-version = testers.testVersion {
    package = finalAttrs.finalPackage;
    command = "rsb_device --version";
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
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
