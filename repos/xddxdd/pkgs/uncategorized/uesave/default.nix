{
  sources,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  inherit (sources.uesave) pname version src;

  cargoHash = "sha256-U6RzSS2j6FK70OHlmWmHZZYT3UB0+Hi+uLofLy+XtGQ=";

  meta = with lib; {
    mainProgram = "uesave";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Library for reading and writing Unreal Engine save files (commonly referred to as GVAS)";
    homepage = "https://github.com/trumank/uesave-rs";
    license = licenses.mit;
  };
}
