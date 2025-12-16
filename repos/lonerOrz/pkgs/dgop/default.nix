{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "dgop";
  version = "0.1.12";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dgop";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-ei6JMAai5azTy4iYLGp6vDd+ADMej+ysrZhlRv491g4=";
  };

  vendorHash = "sha256-MssJTtlKWzn+toNmE+QkXvLXtR7pR21cknXj89CSbwI=";

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
