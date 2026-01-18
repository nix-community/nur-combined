{
  lib,
  stdenv,
  buildGoModule,
  cmake,
  ninja,
  perl,
  pkg-config,

  liboqs,

  sources,
  source ? sources.boringssl-oqs,
}:
buildGoModule (finalAttrs: {
  pname = "boringssl-oqs";
  inherit (source) version src;

  # nix-update auto
  vendorHash = "sha256-jcV7dZZITkvzqKq1EQ4qLiGar568WsDPLtxMvBoh7B8=";
  proxyVendor = true;

  outputs = [
    "out"
    "bin"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    ninja
    perl
    pkg-config
  ];

  buildInputs = [ liboqs ];

  enableParallelBuilding = true;

  cmakeFlags = [
    "-GNinja"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DLIBOQS_DIR=${liboqs}"
    "-DLIBOQS_SHARED=ON"
    "-DBUILD_SHARED_LIBS=ON"
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
    "-DCMAKE_SKIP_INSTALL_RPATH=ON"
  ]
  ++ lib.optional stdenv.isLinux "-DCMAKE_OSX_ARCHITECTURES=";

  preBuild = lib.optionalString (!lib.systems.equals stdenv.hostPlatform stdenv.buildPlatform) ''
    export GOARCH=$(go env GOHOSTARCH)
  '';

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=stringop-overflow"
    "-Wno-error=array-bounds"
  ];

  buildPhase = ''
    runHook cmakeConfigurePhase
    runHook ninjaBuildPhase
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall

    install -Dm755 -t $bin/bin bssl
    install -Dm644 -t $out/lib lib{ssl,crypto,decrepit}${stdenv.hostPlatform.extensions.sharedLibrary}

    mkdir -p $dev
    cp -r ../include $dev

    runHook postInstall
  '';

  meta = {
    description = "Fork of BoringSSL that includes prototype quantum-resistant key exchange and authentication in the TLS handshake based on liboqs";
    changelog = "https://github.com/open-quantum-safe/boringssl/releases/tag/${finalAttrs.version}";
    homepage = "https://openquantumsafe.org";
    license = with lib.licenses; [
      openssl
      isc
      mit
      bsd3
    ];
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "bssl";
    platforms = lib.platforms.linux;
  };
})
