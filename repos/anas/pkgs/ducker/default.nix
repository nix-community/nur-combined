{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
}:

rustPlatform.buildRustPackage rec {
  pname = "ducker";
  version = "0.6.5";

  src = fetchFromGitHub {
    owner = "robertpsoane";
    repo = "ducker";
    rev = "v${version}";
    hash = "sha256-KT76qhAXUV1ShxXD0NVdvIU0RrEimGJt2RRDkqejZ9s=";
  };

  cargoHash = "sha256-gqAB71+9ENTiqUEEJkH5n63a5E1YSiDO0Zvml7DjLr0=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  # There is no tests
  doCheck = false;

  meta = {
    description = "A terminal app for managing docker containers, inspired by K9s";
    homepage = "https://github.com/robertpsoane/ducker";
    changelog = "https://github.com/robertpsoane/ducker/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "ducker";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = with lib.platforms; unix ++ windows;
  };
}
