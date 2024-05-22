{
  sources,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  inherit (sources.uesave) pname version src;

  cargoHash = "sha256-sSiiMtCuSic0PQn4m1Udv2UbEwHUy0VldpGMYSDGh8g=";

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "A library for reading and writing Unreal Engine save files (commonly referred to as GVAS).";
    homepage = "https://github.com/trumank/uesave-rs";
    license = licenses.mit;
  };
}
