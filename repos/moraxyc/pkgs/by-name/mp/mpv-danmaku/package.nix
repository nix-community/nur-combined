{
  lib,
  rustPlatform,
  fetchFromGitHub,

  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mpv-danmaku";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "Kosette";
    repo = "danmaku";
    tag = "v${finalAttrs.version}";
    hash = "sha256-R8235UBkJN1PRghd76ZrZKoKkbGuoOEjD9E/2kIJ5t4=";
  };

  cargoHash = "sha256-vuMwozoLO5FG8nE+DJEGEHTnpqhEhC3oxtH9pUR9Fl0=";

  buildInputs = [ openssl ];

  env = {
    # Use system openssl.
    OPENSSL_DIR = lib.getDev openssl;
    OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
    OPENSSL_NO_VENDOR = true;
  };

  postInstall = ''
    mkdir -p $out/share/mpv/scripts/
    mv $out/lib/libdanmaku.so $out/share/mpv/scripts/danmaku.so
  '';

  stripDebugList = [ "share/mpv/scripts" ];
  passthru.scriptName = "danmaku.so";

  meta = {
    description = "Danmaku plugin for mpv powered by dandanplay API";
    homepage = "https://github.com/Kosette/danmaku";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.linux;
  };
})
