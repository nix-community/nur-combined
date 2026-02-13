{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
rustPlatform.buildRustPackage rec {
  pname = "hazelnut";
  version = "0.2.39";

  src = fetchFromGitHub {
    owner = "ricardodantas";
    repo = "hazelnut";
    rev = "v${version}";
    hash = "sha256-YEcRw/oq47Jtaq0V87WzgwJskkVVCgIYrz1rqqdheiA=";
  };

  cargoHash = "sha256-Vb2c9CCVwW1pYBcWUHM9mrtE8Gk1jNVQSjy3P8rot7Y=";

  meta = {
    description = "Terminal-based automated file organizer inspired by Hazel. Watch folders and organize files with rules.";
    homepage = "https://github.com/ricardodantas/hazelnut";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [renesat];
  };
}
