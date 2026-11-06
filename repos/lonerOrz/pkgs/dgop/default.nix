{
  lib,
  buildGoLatestModule,
  fetchFromGitHub,
}:

buildGoLatestModule (finalAttrs: {
  pname = "dgop";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dgop";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-cIgKTjylOaShxgTedHywHi4Sk3bzSrooY+E2grlK3WU=";
  };

  vendorHash = "sha256-ajtmBCQ4OdIpjOQeiL+hj3e6PL2Np4NLnMAcA1AsW/w=";

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
