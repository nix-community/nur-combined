{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "lrcsnc";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "Endg4meZer0";
    repo = "lrcsnc";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-fXsXRv6h7HfEUhszxSIxv2mnkrm7DLm4Zpw7/beNn2I=";
  };

  vendorHash = "sha256-ww+SXy29woGlb120sj1oGb4MIQJzpBCKGpUKYsYxTMk=";

  ldflags = [
    "-X main.Version=${finalAttrs.version}"
    "-X lrcsnc/internal/setup.version=${finalAttrs.version}"
  ];

  # 测试无法写入缓存目录
  doCheck = false;

  buildFlags = [ "-v" ];

  installPhase = ''
    install -Dm755 $GOPATH/bin/lrcsnc $out/bin/${finalAttrs.pname}
    install -Dm644 LICENSE $out/share/licenses/${finalAttrs.pname}/LICENSE
  '';

  meta = {
    description = "Player-agnostic synced lyrics fetcher and displayer";
    homepage = "https://github.com/Endg4meZer0/lrcsnc";
    mainProgram = "${finalAttrs.pname}";
    binaryNativeCode = true;
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
