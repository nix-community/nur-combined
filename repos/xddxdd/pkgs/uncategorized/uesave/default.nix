{
  sources,
  lib,
  stdenv,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  inherit (sources.uesave) pname version src;

  cargoHash = "sha256-Iz0jndPkX5imEUrFzmfA/RoDfqYhw1XTjk8ttIpjkYE=";

  meta = with lib; {
    description = "A library for reading and writing Unreal Engine save files (commonly referred to as GVAS).";
    homepage = "https://github.com/trumank/uesave-rs";
    license = licenses.mit;
  };
}
