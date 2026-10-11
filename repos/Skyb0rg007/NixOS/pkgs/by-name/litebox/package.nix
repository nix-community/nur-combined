{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  rustPlatform,
  pkg-config,
  openssl,
  diod,
  glibc,
  nodejs-slim,
  python3,
  which,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "litebox";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "litebox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-O6uxFiKxV3ek9Z9U58QNgrLdWc7hAlb7gbxaOZPh6+U=";
  };

  cargoHash = "sha256-UtRxk7fKeqIUz1raRc+oERDNV/BR4muwTo4L8H5UJyY=";

  patches = [
    # Nix store paths make /proc/self/maps larger than the fixed 8 KiB buffer
    # Fixed in https://github.com/microsoft/litebox/pull/1329
    ./0001-platform-linux-userland-grow-proc-self-maps-buffer.patch
    # Make the tests work outside of Debian/Ubuntu and with GCC 16
    ./0002-fix-tests-on-nix.patch
  ];

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
  ];

  # The Windows runner only prints an error on Linux and dev_bench is an
  # internal benchmarking harness.
  cargoBuildFlags = [
    "--package=litebox_packager"
    "--package=litebox_runner_linux_userland"
    "--package=litebox_syscall_rewriter"
  ];

  # The OP-TEE runner must be built separately, since feature unification
  # with litebox_runner_linux_userland selects conflicting syscall ABIs.
  postBuild = ''
    cargo build \
      -j "$NIX_BUILD_CORES" \
      --target ${stdenv.hostPlatform.rust.rustcTargetSpec} \
      --offline \
      --profile "$cargoBuildType" \
      --package=litebox_runner_optee_on_linux_userland
  '';

  useNextest = true;
  # Tests use `cfg(debug_assertions)`-gated helpers
  checkType = "debug";

  nativeCheckInputs = [
    # nixpkgs' diod fails to build with GCC 16 (-Werror=unused-but-set-variable)
    (diod.overrideAttrs { env.NIX_CFLAGS_COMPILE = "-Wno-error=unused-but-set-variable"; })
    nodejs-slim
    python3
    which
  ];

  # The 9P tests attach to diod as $USER, which must match the build user.
  # Tests compile C programs with `gcc -static`; adding glibc.static to
  # checkInputs would make the Rust test binaries link libc.a as well.
  preCheck = ''
    export USER="$(id -un)"
    export LIBRARY_PATH="${lib.getLib glibc.static}/lib''${LIBRARY_PATH:+:$LIBRARY_PATH}"
  '';

  cargoTestFlags = [
    # Repository lints (copyright headers, ratchets) that walk the source tree
    "--filterset"
    "!package(dev_tests)"
  ];

  # nextest does not accept the `--skip=NAME` form
  checkFlags = [
    # Require a preconfigured TUN device
    "--skip"
    "test_tun"
    # Expects a Debian-style /lib/x86_64-linux-gnu with libselinux
    "--skip"
    "test_runner_with_ls"
    # glibc >= 2.42 implements isatty() with TCGETS2, which LiteBox does not
    # support yet, so the guest Python never sees a terminal
    "--skip"
    "test_runner_with_python_repl_pty"
  ];

  postCheck = ''
    cargo nextest run \
      -j "$NIX_BUILD_CORES" \
      --target ${stdenv.hostPlatform.rust.rustcTargetSpec} \
      --offline \
      --show-progress=none \
      --package=litebox_runner_optee_on_linux_userland
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Security-focused library OS";
    license = lib.licenses.mit;
    homepage = "https://github.com/microsoft/litebox";
    changelog = "https://github.com/microsoft/litebox/releases/tag/v${finalAttrs.version}";
    platforms = [ "x86_64-linux" ];
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
