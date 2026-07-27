{ lib, rustPlatform, fetchCrate }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "script-directory-rust";
  version = "0.1.0";

  src = fetchCrate {
    pname = "script-directory";
    inherit (finalAttrs) version;
    hash = "sha256-jJZA1KzExtK+wiMx6ZLEnPA/uqR2ZYRyWP9q3hSPUs8=";
  };

  cargoHash = "sha256-e0m6Zv4AlWybTqnrzzdIEaxm18KVFcOsQ9KiBZ7drHM=";

  meta = {
    description = "Organises and runs all your (oneliner) shellscripts";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ syberant ];
  };
})
