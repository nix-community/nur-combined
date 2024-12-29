{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "ficsit-cli";
  version = "v0.6.0";
  commit = "5dc8bdbaf6e8d9b1bcd2895e389d9d072d454e15";

  src = fetchFromGitHub {
    owner = "satisfactorymodding";
    repo = "ficsit-cli";
    rev = commit;
    hash = "sha256-Zwidx0war3hos9NEmk9dEzPBgDGdUtWvZb7FIF5OZMA=";
  };

  ldflags = [
    "-X=main.version=${version}"
    "-X=main.commit=${commit}"
  ];

  doCheck = false;

  vendorHash = "sha256-vmA3jvxOLRYj5BmvWMhSEnCTEoe8BLm8lpm2kruIEv4=";

  meta = {
    description = "A CLI tool for managing mods for the game Satisfactory ";
    homepage = "https://github.com/satisfactorymodding/ficsit-cli";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ vilsol ];
  };
}
