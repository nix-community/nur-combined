{ lib
, fetchFromGitHub
, rustPlatform
}:

let
  pname = "typepper";
  version = "0.2.0";
  owner = "leodiegues";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub rec {
    inherit owner;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-jojwNMqsSP/8rLP+gxWq8vEKajIz2zHJqrJ0ycRVwWM=";
  };

  cargoHash = "sha256-6nWNz27f90KyDxgtHDznwx4t6Z+bELSiKPs22yNuHCo=";

  # There are no tests
  doCheck = false;


  postInstall = ''
    install -Dm644 ${./typepper.desktop} \
      $out/share/applications/typepper.desktop

    install -Dm644 assets/logo/icon-128.png \
      $out/share/icons/hicolor/128x128/apps/typepper.png
    install -Dm644 assets/logo/icon-256.png \
      $out/share/icons/hicolor/256x256/apps/typepper.png
    install -Dm644 assets/logo/icon-512.png \
      $out/share/icons/hicolor/512x512/apps/typepper.png
    install -Dm644 assets/logo/icon-1024.png \
      $out/share/icons/hicolor/1024x1024/apps/typepper.png
  '';

  meta = {
    description = "A spicy little typing game for your terminal";
    homepage = "https://github.com/leodiegues/typepper";
    license = lib.licenses.gpl3Only;
    mainProgram = "typepper";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = lib.platforms.unix;
  };
}
