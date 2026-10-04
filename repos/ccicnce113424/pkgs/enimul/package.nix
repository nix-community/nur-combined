{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "enimul";
  version = "0.7.2";
  src = fetchFromGitHub {
    owner = "lzpls";
    repo = "enimul";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4tfU9vrBE0x6j5AdBjUZ/w9AOnIY/vID0HtYJDfkpHs=";
  };

  vendorHash = "sha256-MdklXynEG8VWOcsAwgqRz556McYoN0XSh9FrzQseiT0=";

  tags = [ "nodebug" ];

  meta = {
    description = "Lightweight local proxy server that protects TLS connections over TCP";
    homepage = "https://github.com/lzpls/enimul";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "enimul";
  };
})
