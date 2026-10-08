{
  lib,
  rustPlatform,
  fetchzip,
  runCommand,
  lxc,
  bubblewrap,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  coreutils,
  bash,
  wget,
  patchelf,
  iproute2,
  python3,
  util-linux,
  nixosTests,
  withHyperlight ? true,
  withMicrovm ? true,
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

  # Taken from ./src/mxc-sdk/build/nanvix_binaries/versions.json
  versions = builtins.fromJSON (builtins.readFile ./versions.json);
  nanvixVersions = versions.nanvix_python;

  # nanvixd.elf is the host-side microVM daemon and is linked against an FHS
  # loader; everything under bin/ is guest code and must stay untouched.
  nanvixBin =
    runCommand "nanvix-python-${nanvixVersions.tag}"
      {
        src = fetchzip {
          url = "https://github.com/nanvix/nanvix-python/releases/download/${nanvixVersions.tag}/${nanvixVersions.asset_linux}";
          hash = "sha256-ud2quBPm8rP4AUV0edu0sbvgWpF6bLCxhJJvTkNm+wk=";
          postFetch = ''
            mv $out/bin/nanvixd.elf $out
          '';
        };
        nativeBuildInputs = [ patchelf ];
      }
      ''
        cp -r --no-preserve=mode $src $out
        chmod +x $out/nanvixd.elf
        patchelf $out/nanvixd.elf \
          --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
          --set-rpath ${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}
      '';
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mxc";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "mxc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OlDaHOzygPigbBeP1TSrtY96x/Z+jmUsJv4AZ4hGqSg=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  patches = [
    # lxc-exec blocks SIGTERM, SIGINT and SIGHUP for its cleanup watchdog, and
    # std::process::Command keeps the mask across exec. The LXC backend clears
    # it for its children, but the bubblewrap backend does not, so sandboxed
    # workloads cannot be stopped by timeout(1), kill or Ctrl-C.
    ./bwrap-unblock-fatal-signals.patch
  ];

  cargoHash = "sha256-OlWpqsGRlzcIp/QV2Uqso5K1qARaDbWD+Tk5UjFwnlk=";

  env = {
    RUST_BACKTRACE = "1";
    NANVIX_BIN = if stdenv.hostPlatform.isLinux then nanvixBin else null;
  };

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ bubblewrap ];
  buildInputs = [ lxc ];

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
    # The process-with-wslc-section fixture expects the Windows error message;
    # on Linux `process` resolves to bubblewrap and is rejected with another.
    "--skip=sdk_v1_conformance::invalid_documents_are_rejected"
  ];

  # The microVM suite writes its perf results to the repo root, above sourceRoot.
  preCheck = ''
    chmod u+w ..
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
      --replace-fail '"/mnt/wsl/resolv.conf",' '"/mnt/wsl/resolv.conf", "/nix/store", "/run/current-system/sw",'

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

    # The build sandbox has no /bin/sleep; let the sandbox PATH find it.
    substituteInPlace mxc-sdk/tests/wxc_e2e_tests_e2e_bubblewrap_characterization.rs \
      --replace-fail '(/bin/sleep ' '(sleep '
  ''
  + lib.optionalString (stdenv.hostPlatform.isLinux && withMicrovm) ''
    # The build script verifies NANVIX_BIN against checksums.json; record the
    # hash of the patchelf'd nanvixd.elf so the check still applies.
    sed -i -E "s|(\"nanvixd.elf\": \")[0-9a-f]{64}|\1$(sha256sum ${nanvixBin}/nanvixd.elf | cut -d' ' -f1)|" \
      mxc-sdk/build/nanvix_binaries/checksums.json
    grep -qF "$(sha256sum ${nanvixBin}/nanvixd.elf | cut -d' ' -f1)" mxc-sdk/build/nanvix_binaries/checksums.json
  '';

  # The microVM backend looks for the NanVix binaries next to the running
  # executable, so lxc-exec lives beside them in libexec.
  postInstall = lib.optionalString stdenv.hostPlatform.isLinux (
    lib.optionalString withMicrovm ''
      mkdir -p $out/libexec/mxc/bin
      mv $out/bin/lxc-exec $out/libexec/mxc/
      # Staged into the target dir by the build script; linked below instead.
      rm $out/bin/nanvixd.elf
      ln -s ${nanvixBin}/{nanvixd.elf,nanvix_rootfs.img,python3.initrd} $out/libexec/mxc/
      ln -s ${nanvixBin}/bin/kernel.elf $out/libexec/mxc/bin/
      makeWrapper $out/libexec/mxc/lxc-exec $out/bin/lxc-exec \
        --prefix PATH : ${lib.makeBinPath [ bubblewrap ]}
    ''
    + lib.optionalString (!withMicrovm) ''
      wrapProgram $out/bin/lxc-exec \
        --prefix PATH : ${lib.makeBinPath [ bubblewrap ]}
    ''
  );

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
