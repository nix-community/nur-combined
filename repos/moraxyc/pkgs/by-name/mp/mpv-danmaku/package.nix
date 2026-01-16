{
  lib,
  stdenv,
  rustPlatform,
  sources,
  source ? sources.mpv-danmaku,

  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mpv-danmaku";
  inherit (source) version src;

  cargoLock.lockFile = source.cargoLock."Cargo.lock".lockFile;

  buildInputs = [ openssl ];

  env = {
    # Use system openssl.
    OPENSSL_DIR = lib.getDev openssl;
    OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
    OPENSSL_NO_VENDOR = true;
    # ld: symbol(s) not found for architecture arm64
    RUSTFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-C link-arg=-undefined -C link-arg=dynamic_lookup";
  };

  postInstall = ''
    mkdir -p $out/share/mpv/scripts/
    ln -sr $out/lib/libmpv_${finalAttrs.passthru.scriptName} $out/share/mpv/scripts/${finalAttrs.passthru.scriptName}
  '';

  stripDebugList = [ "share/mpv/scripts" ];
  passthru.scriptName = "danmaku${stdenv.hostPlatform.extensions.sharedLibrary}";

  meta = {
    description = "Danmaku plugin for mpv powered by dandanplay API";
    homepage = "https://github.com/moraxyc/danmaku";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
