{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dbus,
  libgcc,
}:

let
  system = stdenv.hostPlatform.system;

  platformMap = {
    "x86_64-linux" = "x86_64";
    "aarch64-linux" = "aarch64";
  };

  # Prebuilt binaries are produced by the upstream CI on every `rs-v*` tag.
  # Checksums are published alongside the tarballs as `<file>.sha256`.
  hashes = {
    "x86_64-linux" = "sha256-xStfl14Dskmdf4lsaglibRR7r8aoJED4jm4gPV85NTs=";
    "aarch64-linux" = "sha256-cDaROh10eSuLs+P3Owb5siJ64LhygMVpnaAuYY4UZc4=";
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "futu-opend-rs";
  version = "1.6.5";

  src = fetchurl {
    url = "https://futuapi.com/releases/rs-v${finalAttrs.version}/futu-opend-rs-${finalAttrs.version}-linux-${platformMap.${system}}.tar.gz";
    hash = hashes.${system};
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  # The binaries are dynamically linked against glibc (libc/libm) plus
  # libgcc_s and libdbus-1 (the latter for the OS keychain / secret-service
  # integration). autoPatchelfHook wires the latter two up to the store.
  buildInputs = [
    dbus.lib
    libgcc.lib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 futu-opend "$out/bin/futu-opend"
    install -Dm755 futu-mcp "$out/bin/futu-mcp"
    install -Dm755 futucli "$out/bin/futucli"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Unofficial Rust reimplementation of Futu's OpenD market-data and trading gateway, with REST, gRPC, WebSocket, CLI and MCP interfaces";
    homepage = "https://futuapi.com/";
    license = licenses.unfree;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames platformMap;
    mainProgram = "futucli";
  };
})
