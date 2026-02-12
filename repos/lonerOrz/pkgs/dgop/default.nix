{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "dgop";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dgop";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-aVnWgTt/fx2yvec+a+/C1xhYeynCQANkBHs6JJUxV6k=";
  };

  vendorHash = "sha256-wDFu46cJoqQTSW11vZ9skuwQg9vZNH4LejoGmo8P75A=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X main.buildTime=1970-01-01_00:00:00"
    "-X main.Commit=${finalAttrs.version}"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp $GOPATH/bin/dgop $out/bin/dgop
  '';

  meta = {
    description = "API & CLI for System Resources";
    homepage = "https://github.com/AvengeMedia/dgop";
    mainProgram = "dgop";
    binaryNativeCode = true;
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
