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
  version = "4.8.5";

  src = fetchFromGitHub {
    owner = "go-musicfox";
    repo = "go-musicfox";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fgzj1L/oIVMCfiWaB83e9GEMyn6lfFSzF/hqq+i+5I0=";
  };

  deleteVendor = true;

  vendorHash = "sha256-j6PFADwjgtOUQlF9rpiOhmLRXUqvqIj1g92HFYUuGFY=";

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
