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
  wget,
  withHyperlight ? true,
  withMicrovm ? true,
}:
let
  linuxPackages = [
    "--package=lxc"
    "--package=lxc_common"
    "--package=wxc_common"
    "--package=bwrap_common"
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

  # Taken from ./src/backends/nanvix/binaries/versions.json
  versions = builtins.fromJSON (builtins.readFile ./versions.json);
  nanvixVersions = versions.nanvix_python;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mxc";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "mxc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-atDxelwxG8AtVFRs+uNR/YPJpGifc0NLGUkQDk0xnuk=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  cargoHash = "sha256-uB5WV9CBfntGkXIRSXCsRt1dLZscgFhTU5mtefNppgs=";

  env = {
    RUST_BACKTRACE = "1";
    NANVIX_BIN =
      if stdenv.hostPlatform.isLinux then
        fetchzip {
          url = "https://github.com/nanvix/nanvix-python/releases/download/${nanvixVersions.tag}/${nanvixVersions.asset_linux}";
          hash = "sha256-ud2quBPm8rP4AUV0edu0sbvgWpF6bLCxhJJvTkNm+wk=";
          postFetch = ''
            mv $out/bin/nanvixd.elf $out
          '';
        }
      else
        null;
  };

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ bubblewrap ];
  buildInputs = [ lxc ];

  cargoBuildFlags = [
    "--features=${lib.concatStringsSep "," buildFeatures}"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux linuxPackages
  ++ lib.optionals stdenv.hostPlatform.isDarwin darwinPackages;
  cargoTestFlags =
    lib.optionals stdenv.hostPlatform.isLinux linuxPackages
    ++ lib.optionals stdenv.hostPlatform.isDarwin darwinPackages;
  checkFlags = [
    "--skip=signal_cleanup::tests::the_watchdogs_view_of_a_container_is_built_and_reset_as_a_single_unit"
    # Expects an external proxy plus blockedHosts to pass policy validation, but
    # external_proxy_host_rules_rejection refuses exactly that before the probe.
    "--skip=bwrap_runner::tests::validate_accepts_host_rules_when_a_proxy_enforces_them_at_0_8"
    "--skip=bwrap_runner::tests::validate_does_not_locally_gate_builtin_test_server"
    # Inspects a descendant through /proc after it may already have been reaped.
    "--skip=bwrap_version::tests::subprocess_probe_terminates_a_descendant_with_closed_pipes"
    # Spawns /bin/true, which the build sandbox lacks.
    "--skip=lxc_bindings::tests::an_unconfined_command_spawns_whoever_the_caller_is"
    # Needs DNS to resolve example.com.
    "--skip=network_iptables::ga_egress_spec::a_legacy_allow_with_blocked_hosts_does_not_open_dns"
  ];

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
    substituteInPlace backends/bubblewrap/common/src/bwrap_command.rs \
      --replace-fail '"/mnt/wsl/resolv.conf",' '"/mnt/wsl/resolv.conf", "/nix/store", "/run/current-system/sw",'

    # Schema 0.9's default block: point its PATH at the store as well.
    substituteInPlace backends/bubblewrap/common/src/bwrap_command.rs \
      --replace-fail 'const DEFAULT_PATH: &str = "${upstreamDefaultPath}";' 'const DEFAULT_PATH: &str = "${defaultSandboxPath}";'

    # build_args emits --clearenv and then only the resolved env, which below
    # schema 0.9 (or when the caller replaces the env outright) carries no PATH.
    # On FHS hosts the sandbox shell's built-in default covers that gap; on
    # NixOS bash defaults to /no-such-path, so nothing on PATH resolves. Supply
    # DEFAULT_PATH when -- and only when -- the resolved env did not set PATH.
    substituteInPlace backends/bubblewrap/common/src/bwrap_command.rs \
      --replace-fail 'args.push("--clearenv".into());' 'args.push("--clearenv".into()); if !resolved_env(request).iter().any(|entry| entry.starts_with("PATH=")) { args.extend(["--setenv".into(), "PATH".into(), DEFAULT_PATH.into()]); }'

    # A test upstream missed when 0.9 replaced ExecutionRequest.schema_version
    # with normalized compatibility fields; 0.8 normalizes to Strict.
    substituteInPlace backends/bubblewrap/common/src/bwrap_runner.rs \
      --replace-fail 'req.schema_version = "0.8.0-alpha".into();' 'req.network_enforcement_compatibility = NetworkEnforcementCompatibility::Strict;'
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/lxc-exec \
      --prefix PATH : ${lib.makeBinPath [ bubblewrap ]}
  '';

  passthru.tests.bwrap =
    runCommand "mxc-bwrap"
      {
        nativeBuildInputs = [
          coreutils
          wget
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
        bash ./tests/scripts/run_bwrap_network_test.sh

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
