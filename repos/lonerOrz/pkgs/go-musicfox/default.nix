{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  flac,
  stdenv,
  alsa-lib,
}:

buildGoModule (finalAttrs: {
  pname = "go-musicfox";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "go-musicfox";
    repo = "go-musicfox";
    rev = "v${finalAttrs.version}";
    hash = "sha256-4BFSusALoxq4KSI4cBcW8tvRcAxH2RlbxT+v7xpkOTA=";
  };

  deleteVendor = true;

  vendorHash = "sha256-ZnARqmLQodUsyyd0NwQYuYD/zcgmaUB72QnIlTHriYc=";

  subPackages = [ "cmd" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/go-musicfox/go-musicfox/internal/types.AppVersion=${finalAttrs.version}"
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    flac
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
  ];

  postInstall = ''
    if [ -f "$out/bin/cmd" ]; then
      mv $out/bin/cmd $out/bin/musicfox
    fi
  '';

  meta = {
    description = "Terminal netease cloud music client written in Go";
    homepage = "https://github.com/anhoder/go-musicfox";
    license = lib.licenses.mit;
    mainProgram = "musicfox";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
