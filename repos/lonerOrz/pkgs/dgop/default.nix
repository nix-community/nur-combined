{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "dgop";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dgop";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-ol44//PHYCH6oLrJFuNJ/mJs+fVICgeLQd8LF3GHYuU=";
  };

  vendorHash = "sha256-kO8b/eV5Vm/Fwzyzb0p8N9SkNlhkJLmEiPYmR2m5+po=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X main.buildTime=1970-01-01_00:00:00"
    "-X main.Commit=${finalAttrs.version}"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp $GOPATH/bin/cli $out/bin/dgop
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
