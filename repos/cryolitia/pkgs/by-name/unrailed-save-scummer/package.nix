{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  pkger,
  gtk3,
  libappindicator-gtk3,
}:

buildGoModule rec {
  pname = "unrailed-save-scummer";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "dudeofawesome";
    repo = "unrailed_save_scummer";
    rev = "v${version}";
    hash = "sha256-E8Hy3V7eXUufzI6SIZn1g+MesGko4nLybFQ2Jntfy+A=";
  };

  nativeBuildInputs = [
    pkg-config
    pkger
  ];

  buildInputs = [
    gtk3
    libappindicator-gtk3
  ];

  preBuild = ''
    ${pkger}/bin/pkger
  '';

  vendorHash = "sha256-FkZ4BNFWCOh9Bqw1wok2nABRvrikqGFRl8zBIcW6YU8=";

  meta = {
    description = "Unrailed deletes saves immediately after loading them, so this program backs them up and replaces them upon deletion";
    homepage = "https://github.com/dudeofawesome/unrailed_save_scummer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Cryolitia ];
    mainProgram = "unrailed_save_scummer";
  };
}
