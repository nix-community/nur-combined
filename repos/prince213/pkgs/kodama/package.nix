{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kodama";
  version = "0.9.9-alpha";

  src = fetchFromGitHub {
    owner = "kokic";
    repo = "kodama";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6uaZkpzEzH40sK8hd9Ey7zNqZ0W/Yo5ZwQp42xq+7Sk=";
  };

  cargoHash = "sha256-YdK4DXmOJx+X6HTNqzH/NVct07SwkL4ZS+zAjjHPQ5g=";

  meta = {
    description = "Typst-friendly static Zettelkästen site generator";
    homepage = "https://github.com/kokic/kodama";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
