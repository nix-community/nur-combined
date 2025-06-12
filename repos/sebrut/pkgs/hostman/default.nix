{
  lib,
  pkgs,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "hostman";
  version = "0.2.0";

  src = pkgs.fetchgit {
    url = "https://codeberg.org/SebRut/hostman";
    branchName = "main";
    rev = "48a20932ad433055b167bda574bdc75a22e9ebea";
    hash = "sha256-pT2MOQd9J9Sw1U+vasefrldnxbXR7fSRnU8O/9vjKQ0=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-AUnv7lZHkbJ0Fk/abVzauXcVoC24YdeA+TEEjRFK05E=";

  meta = with lib; {
    mainProgram = "hostman";
  };
}
