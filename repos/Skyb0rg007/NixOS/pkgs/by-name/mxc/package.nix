{
  lib,
  rustPlatform,
  runCommand,
  lxc,
  bubblewrap,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  makeWrapper,
  pkg-config,
  libgit2,
  openssl,
  zlib,
  coreutils,
  bash,
  wget,
  iproute2,
  python3,
  util-linux,
  nixosTests,
  withHyperlight ? true,
  withMicrovm ? true,
  nix-update-script,
}:
let
  linuxPackages = [
    "--package=lxc"
    "--package=unix_test_proxy"
  ];
  darwinPackages = [
    "--package=mxc_darwin"
    "--package=unix_test_proxy"
  ];
  buildFeatures = lib.optional withHyperlight "hyperlight" ++ lib.optional withMicrovm "microvm";

  # PATH handed to the sandbox when a request supplies no `process.env` PATH.
  # From schema 0.9 upstream sets DEFAULT_PATH itself, but only to the FHS
  # directories, which on NixOS hold nothing but `sh` and `env`. Below 0.9 it
  # still leaves PATH unset and lets the sandbox shell's compile-time default
  # stand in; nixpkgs builds bash with DEFAULT_PATH_VALUE=/no-such-path, so on
  # NixOS that fallback resolves nothing. Most configs under tests/ predate 0.9
  # and set no env, so this has to be fixed here rather than per-config.
  #
  # The host's system profile comes first, as the NixOS analogue of the FHS
  # directories upstream lists next (kept so the value still works on an FHS
  # host, and so upstream's own tests of DEFAULT_PATH hold). The store path is
  # a fallback for contexts where no system profile exists -- notably the Nix
  # build sandbox, where /run/current-system does not exist -- so that
  # upstream's test scripts run unmodified. Nonexistent entries are harmless,
  # and /nix/store is already bound read-only, so this exposes nothing new.
  # /bin supplies sh (bwrap resolves its own `sh -c` command tail through this
  # PATH) and exists both on a NixOS host and in the Nix build sandbox.
  upstreamDefaultPath = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
  defaultSandboxPath = lib.concatStringsSep ":" [
    "/run/current-system/sw/bin"
    upstreamDefaultPath
    "${coreutils}/bin"
  ];

in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mxc";
  version = "1.1.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "mxc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-74e6KZTaErXycDIB5LxQduNvLhv1ULHlHmjmEW7sNmk=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  patches = [
    # lxc-exec blocks SIGTERM, SIGINT and SIGHUP for its cleanup watchdog, and
    # std::process::Command keeps the mask across exec. The LXC backend clears
    # it for its children, but the bubblewrap backend does not, so sandboxed
    # workloads cannot be stopped by timeout(1), kill or Ctrl-C.
    (fetchpatch {
      url = "https://github.com/Skyb0rg007/mxc/commit/c359d2212cb4bda53a3b96911e4278515dee4704.patch";
      relative = "src";
      hash = "sha256-cy9qj7fLqq8ISFAHBYFI7GCl41Z4XI0RxSoQMW9MxvU=";
    })
  ];

  cargoHash = "sha256-yuF5Dn0JnB+gt8mU8lI1exURMImexGNoKgg2zD+tJJc=";

  env.RUST_BACKTRACE = "1";

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];
  nativeCheckInputs = [ bubblewrap ];
  buildInputs = [
    libgit2
    lxc
    openssl
    zlib
  ];

  cargoBuildFlags = [
    "--features=${lib.concatStringsSep "," buildFeatures}"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux linuxPackages
  ++ lib.optionals stdenv.hostPlatform.isDarwin darwinPackages;
  # The backends' unit tests live in the mxc-sdk crate, which is not built
  # (its bins are Windows sandbox daemons).
  cargoTestFlags = [
    "--package=mxc-sdk"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux linuxPackages
  ++ lib.optionals stdenv.hostPlatform.isDarwin darwinPackages;
  checkFlags = [
    "--skip=signal_cleanup::tests::the_watchdogs_view_of_a_container_is_built_and_reset_as_a_single_unit"
    # Inspects a descendant through /proc after it may already have been reaped.
    "--skip=bwrap_version::tests::subprocess_probe_terminates_a_descendant_with_closed_pipes"
    # Spawns /bin/true, which the build sandbox lacks.
    "--skip=lxc_bindings::tests::an_unconfined_command_spawns_whoever_the_caller_is"
    # Timing-sensitive; flaky under a loaded builder.
    "--skip=bwrap_version::tests::subprocess_probe_times_out_and_terminates_the_child"
    "--skip=mxc_pty::tests::native_bridge_cancellation_does_not_inject_eof"
    # Spawns /bin/sleep, which the build sandbox lacks.
    "--skip=mxc_pty::tests::pty_fds_do_not_leak_into_child_across_exec"
    # Sets the setuid bit on a scratch file, which the build sandbox forbids.
    "--skip=bwrap_version::tests::setuid_mode_is_reported_from_the_selected_bwrap_file"
    # The process-with-wslc-section fixture expects the Windows error message;
    # on Linux `process` resolves to bubblewrap and is rejected with another.
    "--skip=sdk_v1_conformance::invalid_documents_are_rejected"
  ];

  # The microVM suite writes its perf results to the repo root, above sourceRoot.
  # The resolver-hint test creates its scratch directory under $HOME.
  preCheck = ''
    chmod u+w ..
    export HOME=$(mktemp -d)
  '';

  # The bubblewrap backend's BASELINE_RO_BIND_PATHS assumes an FHS layout: it
  # binds /bin, /usr/bin, /lib, ... to give the sandbox a shell and the system
  # tools. On NixOS /bin holds only `sh` and /usr/bin only `env`; both are
  # symlinks into /nix/store, and every other system tool lives behind
  # /run/current-system/sw/bin (also symlinks into the store). So we add:
  #   /nix/store            - the real target of every binary and library,
  #                           without which even /bin/sh cannot be executed.
  #   /run/current-system/sw - NixOS's equivalent of /usr, so that the default
  #                           system PATH resolves inside the sandbox.
  # Both are bound read-only, matching the rest of the baseline.
  postPatch = ''
    substituteInPlace mxc-sdk/src/backends/bubblewrap/common/bwrap_command.rs \
      --replace-fail '"/etc",
    ];' '"/etc", "/nix/store", "/run/current-system/sw",
    ];'

    # Schema 0.9's default block: point its PATH at the store as well.
    substituteInPlace mxc-sdk/src/backends/bubblewrap/common/bwrap_command.rs \
      --replace-fail 'const DEFAULT_PATH: &str = "${upstreamDefaultPath}";' 'const DEFAULT_PATH: &str = "${defaultSandboxPath}";'

    # build_args emits --clearenv and then only the resolved env, which below
    # schema 0.9 (or when the caller replaces the env outright) carries no PATH.
    # On FHS hosts the sandbox shell's built-in default covers that gap; on
    # NixOS bash defaults to /no-such-path, so nothing on PATH resolves. Supply
    # DEFAULT_PATH when -- and only when -- the resolved env did not set PATH.
    substituteInPlace mxc-sdk/src/backends/bubblewrap/common/bwrap_command.rs \
      --replace-fail 'args.push("--clearenv".into());' 'args.push("--clearenv".into()); if !resolved_env(request).iter().any(|entry| entry.starts_with("PATH=")) { args.extend(["--setenv".into(), "PATH".into(), DEFAULT_PATH.into()]); }'

    # With PATH empty or unset, bwrap, iptables, slirp4netns and the other host
    # tools are looked up in a fixed list of FHS directories, which hold none of
    # them on NixOS. Search the setuid wrappers and the system profile first.
    substituteInPlace mxc-sdk/src/backends/bubblewrap/common/host_tools.rs \
      --replace-fail 'FALLBACK_DIRECTORIES: [&str; 6] = [' 'FALLBACK_DIRECTORIES: [&str; 8] = ["/run/wrappers/bin", "/run/current-system/sw/bin",'

    # The build sandbox has no /bin/sleep; let the sandbox PATH find it.
    substituteInPlace mxc-sdk/tests/wxc_e2e_tests_e2e_bubblewrap_characterization.rs \
      --replace-fail '(/bin/sleep ' '(sleep '
  '';

  # The unwrapped executable stays in libexec, so that callers can control
  # which bwrap it finds (the NixOS test's version-gate script does).
  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out/libexec/mxc
    mv $out/bin/lxc-exec $out/libexec/mxc/
    makeWrapper $out/libexec/mxc/lxc-exec $out/bin/lxc-exec \
      --prefix PATH : ${lib.makeBinPath [ bubblewrap ]}
  '';

  # The bubblewrap sandbox's PATH when a request supplies none.
  passthru.defaultSandboxPath = defaultSandboxPath;

  passthru.tests.nixos-bwrap = nixosTests.mxc-bwrap;
  passthru.tests.nixos-lxc = nixosTests.mxc-lxc;

  passthru.tests.bwrap =
    runCommand "mxc-bwrap"
      {
        nativeBuildInputs = [
          coreutils
          wget
          iproute2
          python3
          util-linux
        ];
      }
      ''
        set -euo pipefail
        unpackFile ${finalAttrs.src}
        chmod +w -R source
        cd source

        mkdir -p src/target/release
        ln -s ${lib.getExe finalAttrs.finalPackage} src/target/release/lxc-exec

        bash ./tests/scripts/run_bwrap_basic_test.sh
        # The network test needs a host endpoint with a global IPv4 address,
        # but the build sandbox only has loopback. Give it a private network
        # namespace with a dummy interface to listen on. Its probe also runs
        # `bash` from the sandbox's default PATH, so stand in a NixOS system
        # profile at /run/current-system/sw.
        unshare --user --map-root-user --net --mount bash -euo pipefail -c '
          mkdir -p /run
          mount -t tmpfs tmpfs /run
          mkdir -p /run/current-system/sw/bin
          ln -s ${lib.getExe bash} /run/current-system/sw/bin/bash
          ip link set lo up
          ip link add dummy0 type dummy
          ip addr add 192.0.2.1/24 dev dummy0
          ip link set dummy0 up
          bash ./tests/scripts/run_bwrap_network_test.sh
        '

        touch $out
      '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sandboxed code execution system for running untrusted code";
    longDescription = ''
      MXC is a sandboxed code execution system for running untrusted code
      (model output, plugins, tools) on Windows, Linux, and macOS. It provides
      multiple containment backends — from OS-native process sandboxes to full
      VMs — behind a unified JSON configuration schema and TypeScript SDK.
    '';
    homepage = "https://github.com/microsoft/mxc";
    license = lib.licenses.mit;
    mainProgram =
      if stdenv.hostPlatform.isLinux then
        "lxc-exec"
      else if stdenv.hostPlatform.isDarwin then
        "mxc-exec-mac"
      else
        null;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    badPlatforms = [ "aarch64-darwin" ];
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
