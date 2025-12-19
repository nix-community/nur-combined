{
  lib,
  buildGoModule,
  fetchFromSourcehut,
}:

buildGoModule rec {
  pname = "numen";
  version = "0.7";

  src = fetchFromSourcehut {
    owner = "~geb";
    repo = "numen";
    rev = version;
    hash = "sha256-ia01lOP59RdoiO23b5Dv5/fX5CEI43tPHjmaKwxP+OM=";
  };

  vendorHash = "sha256-Y3CbAnIK+gEcUfll9IlEGZE/s3wxdhAmTJkj9zlAtoQ=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "";
    homepage = "https://git.sr.ht/~geb/numen";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "numen";
  };
}
