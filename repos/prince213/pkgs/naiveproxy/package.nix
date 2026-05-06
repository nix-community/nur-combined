{
  apple-sdk_15,
  buildPackages,
  darwin,
  fetchFromGitHub,
  fetchurl,
  gn,
  lib,
  ninja,
  nix-update-script,
  python3,
  replaceVars,
  stdenvNoCC,
  symlinkJoin,
  xcbuild,

  withPgo ? true,
}:
let
  llvmPackages = if withPgo then buildPackages.llvmPackages_22 else buildPackages.rustc.llvmPackages;
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
  version = "148.0.7778.96-3";

  src = fetchFromGitHub {
    owner = "klzgrad";
    repo = "naiveproxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MX8lnw6RkC36v1Vgxci0/JC3yI31Rokv4fGRvePuVH8=";
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

  postPatch =
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
    '';

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
    "dcheck_always_on=true"
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
        url = "https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/chrome-mac-arm-7778-1777396490-28f3bd2de3e5897faaeffb39ece6068b821b4568-01697e67ebd6a170e23bf1503bbc0c3723275c1b.profdata";
        hash = "sha256-gsM4lTXXmAop3n+LGFW2pRwVtIkgp/LOLmaho1Lahhc=";
      };
      x86_64-darwin = fetchurl {
        url = "https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/chrome-mac-7778-1777374771-bf7aebabe8057c6700aa75240777f8557acfd474-d8efa9b284bd43eccbaf67df2d4a1deaa3c39b89.profdata";
        hash = "sha256-gXmewWdgIDMfb8ujTQAoWaK4t3nabp4hXfPXsCxZi4M=";
      };
      any-linux = fetchurl {
        url = "https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/chrome-linux-7778-1777374771-45dd5813b3332165d1d1cd33a478e0a7b948195e-d8efa9b284bd43eccbaf67df2d4a1deaa3c39b89.profdata";
        hash = "sha256-qRbwmZivUpte1ILYnFBusAbRBnv/YDaEoXd46LYeaCw=";
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
