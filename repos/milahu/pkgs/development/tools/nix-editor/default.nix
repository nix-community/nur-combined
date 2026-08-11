{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "nix-editor";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "snowfallorg";
    repo = "nix-editor";
    rev = version;
    hash = "sha256-U0xGyRFvSxWrDdwWwauZ2U8J8jJjssBOefhWOSavo7A=";
  };

  cargoHash = "sha256-t9QkcRY3viyuDuzxVxT/jWUJ4YPN1riLK9pRK4CRkpo=";

  meta = {
    description = "A simple rust program to edit NixOS configuration files with just a command";
    homepage = "https://github.com/snowfallorg/nix-editor";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "nix-editor";
  };
}
