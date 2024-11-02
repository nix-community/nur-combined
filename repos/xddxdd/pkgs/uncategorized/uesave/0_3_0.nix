{
  sources,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "uesave";
  inherit (sources.uesave-0_3_0) version src;

  cargoHash = "sha256-sSiiMtCuSic0PQn4m1Udv2UbEwHUy0VldpGMYSDGh8g=";

  meta = with lib; {
    mainProgram = "uesave";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Library for reading and writing Unreal Engine save files (commonly referred to as GVAS). Older version that works with Palworld";
    homepage = "https://github.com/trumank/uesave-rs";
    license = licenses.mit;
  };
}
