{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "yggmail";
  version = "0-unstable-2024-12-18";

  src = fetchFromGitHub {
    owner = "neilalexander";
    repo = "yggmail";
    rev = "890ef4ada94a0422f6146ee8a0908686b2e88ab5";
    hash = "sha256-WRVhyaFh9Fs6B7ymB5k3ohSfezXjjmn+aTNKjBkaHNk=";
  };

  vendorHash = "sha256-5qwlsZwYIW2V74Qp5or0tTAQk2W1WrpSJVoDE15j2uw=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "End-to-end encrypted email for the mesh networking age";
    homepage = "https://github.com/neilalexander/yggmail";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "yggmail";
  };
}
