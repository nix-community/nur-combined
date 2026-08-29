{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kodama";
  version = "1.1.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "kodama-community";
    repo = "kodama";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hWlMdL6NXlE4vLNNI/3z0mufdE9+jvsjt2rdu+XP3Wk=";
  };

  cargoHash = "sha256-XOCQlXlfTP1TMs3ZZ1NJ4siTm5fcBYSH204f4/uZ/Qg=";

  meta = {
    description = "Typst-friendly static Zettelkästen site generator";
    homepage = "https://github.com/kodama-community/kodama";
    downloadPage = "https://github.com/kodama-community/kodama/releases";
    changelog = "https://github.com/kodama-community/kodama/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
