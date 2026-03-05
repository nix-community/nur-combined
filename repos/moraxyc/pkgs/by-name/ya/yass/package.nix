{
  lib,
  clangStdenv,
  useMoldLinker,
  sources,
  source ? sources.yass,

  c-ares,
  gperftools,
  http-parser,
  jsoncpp,
  mbedtls,
  mimalloc,
  minizip,
  nghttp2,
  sqlite,
  zlib,

  buildPackages,
  cmake,
  installShellFiles,
  ninja,
  pkg-config,
  versionCheckHook,

  enableMold ? false,
  enableFortify ? false,
  withCares ? true,
  withJsoncpp ? true,
  withMbedtls ? true,
  withMimalloc ? false,
  withNghttp2 ? true,
  withSqlite ? true,
  withTcmalloc ? true,
  withZlib ? true,
}:

assert lib.assertMsg (!(withTcmalloc && withMimalloc)) "Cannot use both tcmalloc with mimalloc";

let
  stdenv = if enableMold then useMoldLinker clangStdenv else clangStdenv;
in
stdenv.mkDerivation (finalAttrs: {
  inherit (source) pname version src;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    buildPackages.llvmPackages.bintools
    installShellFiles
  ];

  buildInputs = [
    http-parser
    minizip
  ]
  ++ lib.optional withTcmalloc gperftools
  ++ lib.optional withMimalloc mimalloc
  ++ lib.optional withZlib zlib
  ++ lib.optional withCares c-ares
  ++ lib.optional withNghttp2 nghttp2
  ++ lib.optional withJsoncpp jsoncpp
  ++ lib.optional withMbedtls mbedtls
  ++ lib.optional withSqlite sqlite;

  postPatch = ''
    echo -n "${finalAttrs.version}" > TAG
  '';

  cmakeFlags = with lib.strings; [
    (cmakeFeature "CMAKE_BUILD_TYPE" "Release")
    (cmakeBool "NDEBUG" true)
    (cmakeBool "ENABLE_ASSERTIONS" false)
    (cmakeBool "BUILD_TESTS" true)
    (cmakeBool "CLI" true)
    (cmakeBool "SERVER" true)
    (cmakeBool "GUI" false)

    (cmakeBool "USE_CARES" withCares)
    (cmakeBool "USE_JSONCPP" withJsoncpp)
    (cmakeBool "USE_MBEDTLS" withMbedtls)
    (cmakeBool "USE_MIMALLOC" withMimalloc)
    (cmakeBool "USE_NGHTTP2" withNghttp2)
    (cmakeBool "USE_SQLITE" withSqlite)
    (cmakeBool "USE_TCMALLOC" withTcmalloc)
    (cmakeBool "USE_ZLIB" withZlib)
    (cmakeBool "ENABLE_FORTIFY" enableFortify)
    (cmakeBool "USE_MOLD" enableMold)
    (cmakeBool "USE_LLD" true)
    (cmakeBool "ENABLE_LLD" true)
    (cmakeBool "ENABLE_LTO" true)

    (cmakeBool "USE_SYSTEM_CARES" true)
    (cmakeBool "USE_SYSTEM_HTTP_PARSER" true)
    (cmakeBool "USE_SYSTEM_JSONCPP" (!enableMold))
    (cmakeBool "USE_SYSTEM_MBEDTLS" true)
    (cmakeBool "USE_SYSTEM_MIMALLOC" true)
    (cmakeBool "USE_SYSTEM_MINIZIP" true)
    (cmakeBool "USE_SYSTEM_NGHTTP2" true)
    (cmakeBool "USE_SYSTEM_SQLITE" true)
    (cmakeBool "USE_SYSTEM_TCMALLOC" true)
    (cmakeBool "USE_SYSTEM_ZLIB" true)
  ];

  ninjaFlags = [
    "yass_cli"
    "yass_server"
  ]
  ++ lib.optional finalAttrs.doCheck "yass_test";

  doCheck = true;
  checkPhase = ''
    ./yass_test --gtest_filter='-SSL_TEST.LoadSystemCa:DOH_TEST.*:DOT_TEST.*:CARES_TEST*'
  '';

  postInstall = ''
    substituteInPlace $out/lib/systemd/system/yass*.service \
      --replace-fail '/usr/bin' "$out/bin"
  '';

  doInstallCheck = true;
  nativeCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  meta = {
    description = "NASTY (plugin) client written in C++";
    homepage = "https://github.com/hukeyue/yass";
    license = with lib.licenses; [
      gpl2Only
      cddl
    ];
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.linux;
    mainProgram = "yass_cli";
  };
})
