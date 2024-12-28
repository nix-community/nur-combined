{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "ficsit-cli";
  version = "v0.6.0";

  src = fetchFromGitHub {
    owner = "satisfactorymodding";
    repo = "ficsit-cli";
    rev = version;
    hash = "sha256-Zwidx0war3hos9NEmk9dEzPBgDGdUtWvZb7FIF5OZMA=";
  };

  # doCheck = false;

  patches = [ ./disable-api-test.patch ];

  vendorHash = "sha256-vmA3jvxOLRYj5BmvWMhSEnCTEoe8BLm8lpm2kruIEv4=";

  meta = {
    description = "A CLI tool for managing mods for the game Satisfactory ";
    homepage = "https://github.com/satisfactorymodding/ficsit-cli";
    license = lib.licenses.gpl3;
    maintainers = [ ];
  };
}
