{
  lib,
  buildPackages,
  darwin,
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

  # passthru
  fetchurl,
  nix-update-script,

  withPgo ? true,
}:
let
  llvmPackages =
    if withPgo && (lib.versionOlder buildPackages.rustc.llvmPackages.release_version "22.1") then
      buildPackages.llvmPackages_22
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
  version = "149.0.7827.114-1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "klzgrad";
    repo = "naiveproxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LfBEEshD+/TCstSbF8lkpOi95c2tshBca7wo07XFs7g=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  patches = [
    ./cflags.patch
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isDarwin (
    replaceVars ./libresolv.patch {
      libresolvInc = lib.getInclude darwin.libresolv;
      libresolvLib = lib.getLib darwin.libresolv;
    }
  );

  postPatch = ''
    # ERROR at //.gn:174:30: Assignment had no effect.
    sed -i '/^expand_directory_allowlist =/d' .gn

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
        url = "https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/chrome-mac-arm-7827-1780682012-34f5ad56d61af22a024ee7f6eb8bb6bf6d23a2ce-4185813e9f60e6a1ea3ac12cbce62f4e511cb234.profdata";
        hash = "sha256-f/1dX2gJVo4TTS/Bwbo4zjUazXaze3C5vVUuvb15rVY=";
      };
      x86_64-darwin = fetchurl {
        url = "https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/chrome-mac-7827-1780637531-cc899399c30693429cfd4db2f8b466b9a49952e3-d46fada91c2229327a16ccfd0600864674d6e191.profdata";
        hash = "sha256-C7x79QV3a8PWC/9UzXxOSqQKeZ8GZ7stJ+e/loyk6Lw=";
      };
      any-linux = fetchurl {
        url = "https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/chrome-linux-7827-1780682012-f62c73d731b52a07fffe1a178a38103191b0fddd-4185813e9f60e6a1ea3ac12cbce62f4e511cb234.profdata";
        hash = "sha256-J4jRjfmMpSQKXLLNvbb7lOoVS+HOe1H5qeuR6Ak/clo=";
      };
    };
  };

  meta = {
    description = "Use Chromium's network stack to camouflage traffic";
    homepage = "https://github.com/klzgrad/naiveproxy";
    downloadPage = "https://github.com/klzgrad/naiveproxy/releases";
    changelog = "https://github.com/klzgrad/naiveproxy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "naive";
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
  };
})
