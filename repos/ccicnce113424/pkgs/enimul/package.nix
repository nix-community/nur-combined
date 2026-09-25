{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "enimul";
  version = "0.6.2";
  src = fetchFromGitHub {
    owner = "lzpls";
    repo = "enimul";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NkWmhzoSVsqHx5nD4uAyPdcDkYVYGJfGnaI6Xhfldck=";
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
