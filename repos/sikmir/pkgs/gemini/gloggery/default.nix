{
  lib,
  stdenv,
  fetchFromGitHub,
  go,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gloggery";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "kconner";
    repo = "gloggery";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tWTJXRtm/8cSEbK40fi9PVOg9w/qC0CBFZWyT7vSo80=";
  };

  nativeBuildInputs = [ go ];

  makeFlags = [
    "GOCACHE=$(TMPDIR)/go-cache"
    "HOME=$(out)"
  ];

  preInstall = "install -dm755 $out/{bin,share}";

  postInstall = "mv $out/.gloggery $out/share/glogger";

  meta = {
    description = "Gemtext blog static site generator";
    homepage = "https://github.com/kconner/gloggery";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
