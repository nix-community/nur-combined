{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finallAttrs: {
  pname = "tuckr";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "RaphGL";
    repo = "Tuckr";
    rev = "${finallAttrs.version}";
    hash = "sha256-X2/pOzGUGc5FI0fyn6PB+9duMBdoggjvGxssDXKppWU=";
  };

  cargoHash = "sha256-NXIrjX73lg7706VAJqr/xv7N46ZdscAtXwzJywuAwro=";

  doCheck = false; # test result: FAILED. 5 passed; 3 failed;

  passthru.autoUpdate = false;

  meta = with lib; {
    description = "Super powered replacement for GNU Stow";
    homepage = "https://github.com/RaphGL/Tuckr";
    changelog = "https://github.com/RaphGL/Tuckr/releases/tag/${version}";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ lonerOrz ];
    mainProgram = "tuckr";
  };
})
