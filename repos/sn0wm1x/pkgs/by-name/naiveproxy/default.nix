# Inspired by https://aur.archlinux.org/packages/naiveproxy
{
  lib,
  llvmPackages_22,
  fetchFromGitHub,
  gn,
  ninja,
  python3,
  pkg-config,
  curl,
  openssl,
  symlinkJoin,
  testers,
  nix-update-script,
  callPackage,
}:
let
  stdenv = llvmPackages_22.stdenv;
  clang = symlinkJoin {
    name = "naiveproxy-clang-${llvmPackages_22.llvm.version}";
    paths = [
      llvmPackages_22.clang-unwrapped
      llvmPackages_22.llvm
      llvmPackages_22.lld
    ];
  };
  gnArgs = {
    is_official_build = true;
    is_clang = true;
    clang_base_path = "${clang}";
    clang_use_chrome_plugins = false;
    custom_toolchain = "//build/toolchain/linux/unbundle:default";
    host_toolchain = "//build/toolchain/linux/unbundle:default";
    use_sysroot = false;
    # Chromium's profiles require its newer, prebuilt Clang toolchain.
    chrome_pgo_phase = 0;
    use_clang_modules = false;
    use_unified_system_module = false;
    symbol_level = 0;
    exclude_unwind_tables = true;
    enable_resource_allowlist_generation = false;
    fatal_linker_warnings = false;
    treat_warnings_as_errors = false;

    # Keep the network configuration in upstream src/build.sh.
    is_cronet_build = true;
    use_udev = false;
    use_aura = false;
    use_ozone = false;
    use_gio = false;
    use_platform_icu_alternatives = true;
    use_glib = false;
    is_perfetto_embedder = true;
    disable_file_support = true;
    enable_websockets = false;
    use_kerberos = false;
    disable_zstd_filter = false;
    enable_mdns = false;
    enable_reporting = false;
    include_transport_security_state_preload_list = false;
    enable_device_bound_sessions = false;
    enable_bracketed_proxy_uris = true;
    enable_quic_proxy_support = true;
    enable_disk_cache_sql_backend = false;
    use_nss_certs = false;
    enable_backup_ref_ptr_support = false;
    enable_dangling_raw_ptr_checks = false;
  }
  // lib.optionalAttrs stdenv.hostPlatform.isx86_64 {
    # https://github.com/llvm/llvm-project/issues/86430
    use_cfi_icall = false;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "naiveproxy";
  version = "154.0.8037.49-4";

  src = fetchFromGitHub {
    owner = "klzgrad";
    repo = "naiveproxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qCw0dkXRZbe6faLU0Oyr6dXgZEnh+PnY2rwRuuDzt2Y=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";
  strictDeps = true;
  # Match the mode selected by Chromium for its bundled libc++ headers.
  hardeningEnable = [ "libcxxhardeningextensive" ];

  # Match the LLVM 22 compatibility fixes used by nixpkgs Chromium: these
  # diagnostics, lifetime DSE and UBSan options require Chromium's LLVM 24.
  patches = [ ./llvm-22.patch ];

  nativeBuildInputs = [
    gn
    ninja
    python3
    pkg-config
    llvmPackages_22.lld
  ];

  postPatch = ''
    patchShebangs build tools third_party
  '';

  gnFlags = lib.mapAttrsToList (name: value: "${name}=${builtins.toJSON value}") gnArgs;
  configurePhase = ''
    runHook preConfigure
    export AR=${llvmPackages_22.llvm}/bin/llvm-ar
    export NM=${llvmPackages_22.llvm}/bin/llvm-nm
    gn gen out/Release --args="$gnFlags"
    runHook postConfigure
  '';

  ninjaFlags = [
    "-C"
    "out/Release"
    "naive"
  ];
  doCheck = true;
  nativeCheckInputs = [
    curl
    openssl
  ];
  checkPhase = ''
    runHook preCheck
    python3 ../tests/basic.py --naive="$PWD/out/Release/naive"
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 out/Release/naive "$out/bin/naiveproxy"
    install -Dm644 ../USAGE.txt "$out/share/doc/naiveproxy/USAGE.txt"
    install -Dm644 ../README.md "$out/share/doc/naiveproxy/README.md"
    install -Dm644 config.json "$out/share/doc/naiveproxy/config.json.example"
    install -Dm644 ../LICENSE "$out/share/licenses/naiveproxy/LICENSE"
    runHook postInstall
  '';

  passthru = {
    tests = {
      version = testers.testVersion {
        package = finalAttrs.finalPackage;
        command = "naiveproxy --version";
        version = lib.head (lib.splitString "-" finalAttrs.version);
      };
      integration = callPackage ./tests.nix {
        naiveproxy = finalAttrs.finalPackage;
        caddy = callPackage ../caddy-sn0wm1x { };
      };
    };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Make a fortune quietly";
    homepage = "https://github.com/klzgrad/naiveproxy";
    changelog = "https://github.com/klzgrad/naiveproxy/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    mainProgram = "naiveproxy";
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = lib.platforms.linux;
  };
})
