{
  lib,
  buildGoLatestModule,
  fetchFromGitHub,
}:

buildGoLatestModule (finalAttrs: {
  pname = "dgop";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dgop";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-GTDomQTBU132DVjqX/o3cZBo9ylUWLvUJ74PSlahgTo=";
  };

  vendorHash = "sha256-bVrNwxylrKkmDWdrw+G/yi3DgVdRZtOVn53HfmpXjJk=";

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
