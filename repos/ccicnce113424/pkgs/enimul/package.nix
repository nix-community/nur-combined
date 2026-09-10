{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "enimul";
  version = "0.6.0";
  src = fetchFromGitHub {
    owner = "lzpls";
    repo = "enimul";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5p0ioUtwhkSfSAkPTOT14pSa6WjxzQykxTHl9szE7zQ=";
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
