{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  flac,
  stdenv,
  alsa-lib,
}:

buildGoModule rec {
  pname = "go-musicfox";
  version = "4.7.2";

  src = fetchFromGitHub {
    owner = "go-musicfox";
    repo = "go-musicfox";
    rev = "v${version}";
    hash = "sha256-RJPb+aZawU22HBXTfr7+TP0ocFsNrP1mOHvHPRm2RnA=";
  };

  deleteVendor = true;

  vendorHash = "sha256-KQp22eF48jhhCSZA/1weWVavyP3be4j4mOPM5EPssGs=";

  subPackages = [ "cmd/musicfox.go" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/go-musicfox/go-musicfox/internal/types.AppVersion=${version}"
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

  meta = {
    description = "Terminal netease cloud music client written in Go";
    homepage = "https://github.com/anhoder/go-musicfox";
    license = lib.licenses.mit;
    mainProgram = "musicfox";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
