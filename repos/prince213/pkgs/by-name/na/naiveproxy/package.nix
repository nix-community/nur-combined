{
  lib,
  buildPackages,
  fetchFromGitHub,
  replaceVars,
  stdenvNoCC,
  symlinkJoin,

  # nativeBuildInputs
  gn,
  ninja,
  python3,
  xcbuild,

  # buildInputs
  apple-sdk_15,
  darwin,

  # passthru
  fetchurl,
  nix-update-script,

  withPgo ? true,
}:
let
  llvmPackages =
    if withPgo && (lib.versionOlder buildPackages.rustc.llvmPackages.release_version "23.1") then
      buildPackages.llvmPackages_23
    else
      buildPackages.rustc.llvmPackages;
  llvmCcAndBintools = symlinkJoin {
    name = "llvmCcAndBintools";
    paths = [
      llvmPackages.llvm
      llvmPackages.stdenv.cc
    ];
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "naiveproxy";
  version = "154.0.8037.49-4";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "klzgrad";
    repo = "naiveproxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qCw0dkXRZbe6faLU0Oyr6dXgZEnh+PnY2rwRuuDzt2Y=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  patches = lib.optional stdenvNoCC.hostPlatform.isDarwin (
    replaceVars ./libresolv.patch {
      libresolvInc = lib.getInclude darwin.libresolv;
      libresolvLib = lib.getLib darwin.libresolv;
    }
  );

  postPatch = ''
    patchShebangs --build build/toolchain/apple/linker_driver.py
  ''
  + (
    let
      pgoProfile =
        finalAttrs.passthru.pgoProfiles.${
          if stdenvNoCC.hostPlatform.isDarwin then
            stdenvNoCC.hostPlatform.system
          else if stdenvNoCC.hostPlatform.isLinux then
            "any-linux"
          else
            throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}"
        };
    in
    lib.optionalString withPgo ''
      mkdir -p chrome/build/pgo_profiles
      cp ${pgoProfile} chrome/build/pgo_profiles/${pgoProfile.name}
    ''
  );

  nativeBuildInputs = [
    llvmPackages.bintools
    gn
    ninja
    python3
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isDarwin xcbuild;

  buildInputs = lib.optional stdenvNoCC.hostPlatform.isDarwin apple-sdk_15;

  gnFlags = [
    "clang_base_path=\"${llvmCcAndBintools}\""
    "clang_use_chrome_plugins=false"

    "is_official_build=true"
    "is_chrome_branded=true"
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
    "use_clang_modules=false"
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin [
    "mac_allow_system_xcode_for_official_builds_for_testing=true"
    "enable_dsyms=false"
  ]
  ++ lib.optional (
    stdenvNoCC.hostPlatform.isLinux && stdenvNoCC.hostPlatform.isx86_64
  ) "use_cfi_icall=false"
  ++ lib.optional withPgo "chrome_pgo_phase=2";

  ninjaFlags = [ "naive" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 naive $out/bin/naive

    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script { };
    pgoProfiles = {
      aarch64-darwin = fetchurl {
        url = "https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/chrome-mac-arm-8037-1789514271-354a99ee3138b99ca5663d169539bc1a82b1eca7-01b870b743c773a6d66e8b1c5294a95ac51cd3b0.profdata";
        hash = "sha256-aVtsXGPN6wf5OO5MMjCSIxBTkyXT7bINDqGCnnSjIMg=";
      };
      x86_64-darwin = fetchurl {
        url = "https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/chrome-mac-8037-1789495081-eebf3ce77b36a1ad15bece90fb99aefb70206bb6-9272cb3a6934b0e4510fb1cde78ca7e9d7859922.profdata";
        hash = "sha256-bg6BoaK2aCxU7+aGLrtiMAXC5n4M43kFZR24Lib1LLY=";
      };
      any-linux = fetchurl {
        url = "https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/chrome-linux-8037-1789495081-7feb9cdd3829d739633f8ac2c1a41d6c0f693bd3-9272cb3a6934b0e4510fb1cde78ca7e9d7859922.profdata";
        hash = "sha256-Hh953Ett5yvM+8LmdJjnXOYMS1PBC86wVZw1hZbNcaI=";
      };
    };
  };

  meta = {
    description = "Use Chromium's network stack to camouflage traffic";
    homepage = "https://github.com/klzgrad/naiveproxy";
    downloadPage = "https://github.com/klzgrad/naiveproxy/releases";
    changelog = "https://github.com/klzgrad/naiveproxy/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "naive";
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
  };
})
