{ fetchFromGitHub
, lib
, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "hatsu";
  version = "0.3.0-beta.4";

  src = fetchFromGitHub {
    owner = "importantimport";
    repo = "hatsu";
    rev = "refs/tags/v${version}";
    hash = "sha256-UKrnFI79+SHSqAlUWQiAMrTT+Nu+YwG77YGa8dHNPgY=";
  };

  cargoHash = "sha256-DSYj1lCO2ll14ysykRiZ5NQIiAKwKYqVMwCCUENJ0Rc=";

  meta = {
    description = "Self-hosted and fully-automated ActivityPub bridge for static sites";
    homepage = "https://github.com/importantimport/hatsu";
    downloadPage = "https://github.com/importantimport/hatsu/releases";
    changelog = "https://github.com/importantimport/hatsu/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "hatsu";
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = lib.platforms.linux;
  };
}
