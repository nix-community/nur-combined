{ stdenv
, fetchurl
, fetchFromGitHub
  # , autoPatchelfHook
  # , gn
, gn1924
, ninja
, python3
, llvmPackages_19
, lib
, ...
}:
let
  pgoPath = "chrome-linux-6613-1723571743-978bf352c6598979c1835e8a17c4382c57186e27-bfa8880547ba8b84e6f5efee6db486daf237d00d.profdata";
  pgoProfile = fetchurl {
    url = "https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/${pgoPath}";
    hash = "sha256-aW5HnNr/AqRGyjRGsyeQyJFEFWo135DJCxgG0qzkKbQ=";
  };

in
stdenv.mkDerivation rec {
  pname = "naiveproxy";
  version = "128.0.6613.40-1";

  src = fetchFromGitHub {
    repo = "naiveproxy";
    owner = "klzgrad";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-dOaGjpfrNlVxbf6BHiEqJkpPIbwWC0Gl2LaKzu0DUxA=";
  };

  sourceRoot = "${src.name}/src";

  nativeBuildInputs = [
    # autoPatchelfHook
    gn1924
    ninja
    python3
  ];
  buildInputs = [ stdenv.cc.cc.libgcc ];

  gnFlags = [
    # https://github.com/klzgrad/naiveproxy/blob/23efc88f26cb9a4332b3568d4d08eed888814cbb/src/build.sh#L15-L19
    "is_official_build=true"
    "exclude_unwind_tables=true"
    "enable_resource_allowlist_generation=false"
    "symbol_level=0"

    # https://github.com/klzgrad/naiveproxy/blob/23efc88f26cb9a4332b3568d4d08eed888814cbb/src/build.sh#L46-L74
    "is_clang=true"
    "use_sysroot=false"

    "fatal_linker_warnings=false"
    "treat_warnings_as_errors=false"

    "enable_base_tracing=false"
    "use_udev=false"
    "use_aura=false"
    "use_ozone=false"
    "use_gio=false"
    "use_gtk=false"
    "use_platform_icu_alternatives=true"
    "use_glib=false"
    "enable_js_protobuf=false"

    "disable_file_support=true"
    "enable_websockets=false"
    "use_kerberos=false"
    "enable_mdns=false"
    "enable_reporting=false"
    "include_transport_security_state_preload_list=false"
    "use_nss_certs=false"
    "enable_device_bound_sessions=false"

    "enable_backup_ref_ptr_support=false"
    "enable_dangling_raw_ptr_checks=false"
  ]
  # https://github.com/klzgrad/naiveproxy/blob/23efc88f26cb9a4332b3568d4d08eed888814cbb/src/build.sh#L96-L100
  ++ lib.optional stdenv.isx86_64 "use_cfi_icall=false";

  postPatch = ''
    # patch pgo
    mkdir -p chrome/build/pgo_profiles
    cp ${pgoProfile}                          chrome/build/pgo_profiles/${pgoPath}

    # patch chromium-browser-clang
    mkdir -p third_party/llvm-build/Release+Asserts/bin
    ln -s ${llvmPackages_19.clang}/bin/clang              third_party/llvm-build/Release+Asserts/bin/clang
    ln -s ${llvmPackages_19.clang}/bin/clang++            third_party/llvm-build/Release+Asserts/bin/clang++
    ln -s ${llvmPackages_19.llvm}/bin/llvm-ar    third_party/llvm-build/Release+Asserts/bin/llvm-ar
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 out/Release/naive  $out/bin/naiveproxy

    mkdir -p $out/share/doc/naiveproxy
    install -Dm644 README.md $out/share/doc/naiveproxy/README.md
    install -Dm644 USAGE.txt $out/share/doc/naiveproxy/USAGE.txt

    mkdir -p $out/share/licenses/naiveproxy
    install -Dm644 LICENSE $out/share/licenses/naiveproxy/LICENSE

    runHook postInstall
  '';

  meta = {
    broken = true; # WIP
    description = "Make a fortune quietly";
    homepage = "https://github.com/klzgrad/naiveproxy";
    downloadPage = "https://github.com/klzgrad/naiveproxy/releases";
    changelog = "https://github.com/klzgrad/naiveproxy/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    mainProgram = "naiveproxy";
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = lib.platforms.linux;
  };
}
