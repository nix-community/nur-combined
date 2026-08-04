{
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  name = "project";

  src = lib.cleanSource ./.;

  cargoHash = "";

  meta = {
    description = "Project description";
    #homepage = "https://project.page";
    license = lib.licenses.gpl3Only;
    #mainProgram = "project";
  };
}
