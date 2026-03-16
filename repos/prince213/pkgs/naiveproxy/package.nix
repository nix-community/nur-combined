{
  buildPackages,
  fetchFromGitHub,
  gn,
  lib,
  ninja,
  python3,
  stdenvNoCC,
  symlinkJoin,
}:
let
  llvmCcAndBintools = symlinkJoin {
    name = "llvmCcAndBintools";
    paths = [
      buildPackages.rustc.llvmPackages.llvm
      buildPackages.rustc.llvmPackages.stdenv.cc
    ];
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "naiveproxy";
  version = "143.0.7499.109-2";

  src = fetchFromGitHub {
    owner = "klzgrad";
    repo = "naiveproxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QC8ygQYRkGyg+ZQq9SHkdv65+JTSXzknMU4zU7z6O6Y=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  nativeBuildInputs = [
    buildPackages.rustc.llvmPackages.bintools
    gn
    ninja
    python3
  ];

  gnFlags = [
    "clang_base_path=\"${llvmCcAndBintools}\""
    "clang_use_chrome_plugins=false"

    "is_official_build=true"
    "exclude_unwind_tables=true"
    "enable_resource_allowlist_generation=false"
    "symbol_level=0"
    "is_clang=true"
    "use_sysroot=false"
    "fatal_linker_warnings=false"
    "treat_warnings_as_errors=false"
    "is_cronet_build=true"
    "use_udev=false"
    "use_aura=false"
    "use_ozone=false"
    "use_gio=false"
    "use_platform_icu_alternatives=true"
    "use_glib=false"
    "is_perfetto_embedder=true"
    "disable_file_support=true"
    "enable_websockets=false"
    "use_kerberos=false"
    "disable_file_support=true"
    "disable_zstd_filter=false"
    "enable_mdns=false"
    "enable_reporting=false"
    "include_transport_security_state_preload_list=false"
    "enable_device_bound_sessions=false"
    "enable_bracketed_proxy_uris=true"
    "enable_quic_proxy_support=true"
    "enable_disk_cache_sql_backend=false"
    "use_nss_certs=false"
    "enable_backup_ref_ptr_support=false"
    "enable_dangling_raw_ptr_checks=false"
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isDarwin "enable_dsyms=false"
  ++ lib.optional (
    stdenvNoCC.hostPlatform.isLinux && stdenvNoCC.hostPlatform.isx86_64
  ) "use_cfi_icall=false";

  ninjaFlags = [ "naive" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 naive $out/bin/naive

    runHook postInstall
  '';

  meta = {
    description = "Use Chromium's network stack to camouflage traffic";
    homepage = "https://github.com/klzgrad/naiveproxy";
    downloadPage = "https://github.com/klzgrad/naiveproxy/releases";
    changelog = "https://github.com/klzgrad/naiveproxy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "naive";
    platforms = with lib.platforms; darwin ++ linux;
  };
})
