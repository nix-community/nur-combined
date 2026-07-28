{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "maelstrom-matrix";
  version = "0-unstable-2026-04-14";

  src = fetchFromGitHub {
    owner = "maelstrom-rs";
    repo = "maelstrom";
    rev = "3a41e4cada2ee934f5035d3e9a9fbfb476162713";
    hash = "sha256-NZeOePEPm61UrBRMk0f6dlZL+0mfJo1eotUW7j42Kvw=";
  };

  cargoHash = "sha256-sa9QWVWODhhwzklTWRpxyMBHp/11XkXQj1OM2EythJc=";
})
